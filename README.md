## dotfiles

Everything under `home/` and `desktop/` mirrors `~`, and [GNU Stow](https://www.gnu.org/software/stow/)
puts it there. `home/` is everything that's useful over ssh (zsh, nvim, tmux, ...), `desktop/` is
the sway session on top (sway, waybar, kitty, the menu scripts, ...). From the root of the repo:

```sh
./install --deps              # laptop: packages + home + desktop
./install --deps --headless   # dev box: packages + home only
```

`install` is a thin wrapper: `stow -R` over the packages for the profile, plus `--deps` to
`dnf`/`apt-get` install what they need (lists at the top of the script). Without it, it's just
`stow home desktop` or `stow home`. `.stowrc` supplies `--no-folding` and `--target=~`, so there
are no flags to remember. `--no-folding` just does the symlinking at file level so you keep files
ignored in the .config dirs, and lets both packages share `.local/bin`.

Useful stuff (anything `install` doesn't recognise goes to stow):

```sh
./install -n -v       # dry run, prints exactly what it would do
./install             # re-stow; also clears links for files deleted from the repo
./install -D          # remove every link, leaving machine-owned files alone
```

When adding a config, put it in `desktop/` if it only means something with a display.

## Next steps

```sh
treesitter-install                   # nvim parsers, see Treesitter below
sudo dnf install gopls               # or apt-get
uv tool install python-lsp-server    # pylsp
uv tool install ruff
setup-gnome                          # if GNOME is installed too: tweaks its defaults, e.g. sway-style workspaces
```

terraform-ls comes from [HashiCorp's repo](https://developer.hashicorp.com/terraform/install), and
lua-language-server is a [release](https://github.com/LuaLS/lua-language-server/releases) unpacked
into `~/.local/opt` with its `bin/lua-language-server` linked into `~/.local/bin`. nvim only starts
the servers it can find.

## Dependencies

Installed by `./install --deps`, except:

```
ffmpeg            # screen-record gifs; Fedora needs rpmfusion, see below
alacritty         # optional
```

brightnessctl on debian/ubuntu also wants `usermod -aG video $USER` and a relogin.

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
