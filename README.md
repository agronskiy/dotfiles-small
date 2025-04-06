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
curl -sL https://raw.githubusercontent.com/agronskiy/dotfiles-small/main/install.sh | bash
```
## Features

### Tmux

* `<F12>` toggles outer tmux to enabled/disabled, useful when having nested tmux
* `osc-52` works for arbitrary chains of nested tmux/ssh/vim to copy stuff
* pane navigation works seamlessly using `Ctrl-<hjkl>` _across_ vim and tmux panes, see Neovim section
* `<Ctrl-Space>` as `prefix`
* `<F8>` to, for a given window `win`, create automatically a `[term]` window to the right, and subsequently switch between the two.
  Usecase: have pairs of dev and terminal windows to quickly switch between them
