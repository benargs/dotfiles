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
stow zsh fzf tmux neovim kitty

# desktop
sway swaybg swayidle swaylock waybar mako fuzzel
grim slurp wl-clipboard swappy brightnessctl playerctl

# look
jetbrains-mono-fonts (fonts-jetbrains-mono)
fontawesome-6-free-fonts (fonts-font-awesome)
adw-gtk3-theme

# optional
alacritty
```


