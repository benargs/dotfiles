#!/bin/sh
# NOTE: This is an entirely llm generated script to try debug an intermittent issue
# on some of the laptops. It'll get dropped out of the dots once i've debugged.

# Snapshot display state. Run this WHILE a monitor is black -- before unplugging or
# reloading, since both destroy the evidence.
#
#   ~/.config/sway/dpy-debug.sh            # print
#   ~/.config/sway/dpy-debug.sh > /tmp/dpy # keep
# ---------------------------------------------------------------------------------
# WHAT TO LOOK FOR, in order:
#
# 1. Compare the "sway" block against the "kernel" block. They disagreeing IS the
#    finding. sway saying active=true while the kernel says enabled=disabled means the
#    driver dropped that stream behind sway's back -- almost always to light another
#    one. Fix is to lower the OTHER monitor's mode, not this one's.
#
# 2. power=false means nothing was evicted; something just turned it off. The likely
#    culprit is swayidle: it runs 'output * power off' on idle and 'output * power on'
#    on resume, and the resume can race. Recover with:
#        swaymsg output <NAME> power on
#    If turning it on knocks a DIFFERENT monitor off, that is bandwidth (see above).
#
# 3. mode=NONE means sway has the output but never set a resolution. Either the mode in
#    ~/.config/sway/local does not exist on that panel (check the exact refresh --
#    2560x1440@60Hz does NOT exist on these Dells, only @59.951), or the mode-set failed
#    for bandwidth. List what the panel really offers:
#        swaymsg -t get_outputs | jq '.[]|select(.name=="DP-3").modes'
#
# 4. vrr=enabled on a monitor that blacks out intermittently is the prime suspect on the
#    ThinkPads. The shared config sets 'output * adaptive_sync on' for every output. To
#    test, put this in ~/.config/sway/local (it is included last, so it wins):
#        output * adaptive_sync off
#    then swaymsg reload. On the Latitude VRR reports disabled anyway (Kaby Lake will not
#    do it over the TB tunnel), so this only matters on the newer machines.
#
# 5. An empty DRM message section is itself informative: no link-training or bandwidth
#    errors means the hardware is not failing, which points at sway/swayidle state (2)
#    rather than the physical link.
#
# 6. If the kernel lists a connector as connected but sway shows no such output, sway
#    missed the hotplug -- swaymsg reload usually recovers it.
# ---------------------------------------------------------------------------------
set -eu

echo "=== $(date -Is)  $(hostnamectl --static 2>/dev/null || hostname) ==="

echo "--- sway ---"
swaymsg -t get_outputs | jq -r '.[] |
  "  \(.name)  active=\(.active) power=\(.power) dpms=\(.dpms) vrr=\(.adaptive_sync_status)  " +
  "\(.rect.width)x\(.rect.height)@(\(.rect.x),\(.rect.y))  " +
  "mode=\(if .current_mode then "\(.current_mode.width)x\(.current_mode.height)@\(.current_mode.refresh/1000)" else "NONE" end)  " +
  "\(.make) \(.model)"'

echo "--- kernel (what the driver actually has lit) ---"
for c in /sys/class/drm/card*-*/; do
  [ -f "$c/status" ] || continue
  [ "$(cat "$c/status")" = connected ] || continue
  printf '  %-22s enabled=%-9s dpms=%s\n' \
    "$(basename "$c")" "$(cat "$c/enabled" 2>/dev/null)" "$(cat "$c/dpms" 2>/dev/null)"
done

echo "--- recent DRM kernel messages ---"
journalctl -k -b 0 --no-pager 2>/dev/null \
  | grep -Ei 'drm|i915|xe ' \
  | grep -Ei 'link|train|mst|bandwidth|fail|error|timeout|hpd|atomic' \
  | tail -20 || echo "  (none)"

echo "--- interpretation ---"
echo "  power=false            -> sway/swayidle turned it off (idle resume race)"
echo "  mode=NONE / 0x0        -> no mode set: bandwidth or link training failure"
echo "  enabled=disabled       -> driver dropped it, sway may still think it is fine"
echo "  vrr=enabled + blackout -> suspect adaptive_sync on that output"
