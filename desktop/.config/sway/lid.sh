#!/bin/sh
set -eu

internal=$(swaymsg -t get_outputs \
  | jq -r '[.[] | select(.name | test("^(eDP|LVDS|DSI)"))][0].name // empty')
[ -n "$internal" ] || exit 0

case "${1:-}" in
close)
  # guard against disabling laptop screen when other is detected but inactive
  others=$(swaymsg -t get_outputs \
    | jq --arg i "$internal" '[.[] | select(.name != $i and .active)] | length')
  [ "$others" -gt 0 ] || exit 0
  swaymsg output "$internal" disable
  ;;
open)
  swaymsg output "$internal" enable
  ;;
esac
