## dotfiles

Everything under `home/` mirrors `~`, and [GNU Stow](https://www.gnu.org/software/stow/)
puts it there. From the root of the repo, simply run:

```sh
dnf/apt/... install stow 
stow home
```

`.stowrc` supplies `--no-folding` and `--target=~`, so there are no flags to remember.
`--no-folding` just does the symlinking at file level so you keep files ignored in the
.config dirs.

Useful stuff:

```sh
stow -n -v home       # dry run, prints exactly what it would do
stow -R home          # re-stow; also clears links for files deleted from the repo
stow -D home          # remove every link, leaving machine-owned files alone
```

## Dependencies

```
# shell
stow zsh fzf tmux neovim kitty jq tree-sitter-cli

# desktop
sway swaybg swayidle swaylock waybar mako fuzzel
grim slurp wl-clipboard swappy playerctl
wf-recorder ffmpeg                # screen-record (ffmpeg only for gifs)
brightnessctl                     # debian/ubuntu: also `usermod -aG video $USER`, relogin
xdg-desktop-portal-wlr pipewire   # screen sharing

# look
jetbrains-mono-fonts (fonts-jetbrains-mono)
fontawesome-6-free-fonts (fonts-font-awesome)
adw-gtk3-theme

# optional
alacritty
```

## Video codecs (Fedora)

```sh
sudo dnf install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
```

## Treesitter

No nvim-treesitter plugin. Parsers are pinned in `home/.config/nvim/treesitter.json` (url +
commit; `subdir` for grammars inside a bigger repo, e.g. terraform in tree-sitter-hcl).
`treesitter-install [lang...]` builds them and fetches their queries from nvim-treesitter at
the commit pinned in the script (`NVIM_TS_REF`) - the same commit the json hashes came from,
so parsers and queries match. `treesitter.lua` highlights whatever the json lists (+builtins).

Adding or updating a language: take its url + revision from nvim-treesitter's
`lua/nvim-treesitter/parsers.lua` at `NVIM_TS_REF` into the json, `treesitter-install <lang>`.
To move everything forward, bump `NVIM_TS_REF` and redo the hashes from that commit's parsers.lua.

## Migrating ~/repos to ~/src

The stow links are relative, so moving the checkout breaks them all. Unstow, move and restow
in one go (close tmux/nvim sessions in `~/repos` first):

```sh
cd ~/repos/benargs/dotfiles && stow -D home && mv ~/repos ~/src && cd ~/src/benargs/dotfiles && stow home
```
