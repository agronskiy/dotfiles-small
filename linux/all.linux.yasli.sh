#!/usr/bin/env bash

# neovim
# this installer assumes all the lazy installations into `agnvim` appname to avoid
# clashes with other installs
install_neovim() {
    [ -d "$HOME/.local/bin/neovim-install" ] && rm -rf "$HOME/.local/bin/neovim-install"
    mkdir -p "$HOME/.local/bin/neovim-install"
    cd $HOME/.local/bin/neovim-install \
    && curl -LO https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-linux64.tar.gz \
    && tar xzvf nvim-linux64.tar.gz \
    && ln -s --force "$(realpath ./nvim-linux64/bin/nvim)" "$HOME/.local/bin/nvim" \
    && NVIM_APPNAME='agnvim' $HOME/.local/bin/nvim --headless '+Lazy! install' +qa
}
exists_neovim() {
  [ -x "$(command -v nvim)" ] && nvim --version | grep -q "0.10.2"
}
install_wrapper "neovim" install_neovim exists_neovim

# rg
install_ripgrep() {
    [ -d "$HOME/.local/bin/ripgrep-install" ] && rm -rf "$HOME/.local/bin/ripgrep-install"
    mkdir -p "$HOME/.local/bin/ripgrep-install"
    cd $HOME/.local/bin/ripgrep-install \
    && curl -LO 'https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep-13.0.0-x86_64-unknown-linux-musl.tar.gz' \
    && tar xzvf ripgrep-13.0.0-x86_64-unknown-linux-musl.tar.gz \
    && ln -s --force "$(realpath ./ripgrep-13.0.0-x86_64-unknown-linux-musl/rg)" "$HOME/.local/bin/rg"
}
exists_ripgrep() {
    [ -x "$(command -v rg)" ]
}
install_wrapper "ripgrep" install_ripgrep exists_ripgrep

