Small version of https://github.com/agronskiy/dotfiles intended to:

- contain only absolutely necessary binaries for operating remote Linux boxes after
  quick ssh-ing
- not depend on `sudo` or `apt-get`
- not using zsh
- not supporting Darwin

## Contains

- neovim 10.0 together with heavily stripped set of plugins (no LSP, no fancy things like markdown
  renderer, only things abvolustely needed for comfortable work)
- tmux 3.5 as a standaolone built binary
- fzf
- ripgrep (needed for some fzf work)

## Installation

```
https://raw.githubusercontent.com/agronskiy/dotfiles-small/main/install.sh | bash
```
