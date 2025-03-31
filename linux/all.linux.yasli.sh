#!/usr/bin/env bash

install_tmux() {
    [ -d /tmp/tmux-install ] && rm -rf /tmp/tmux-install
    mkdir /tmp/tmux-install
    (
        cd /tmp/tmux-install
        $SUDO_CMD apt-get -y install libncurses5-dev libncursesw5-dev autoconf automake pkg-config libevent-dev bison byacc \
        && git clone https://github.com/tmux/tmux.git \
        && cd tmux \
        && sh autogen.sh \
        && ./configure \
        && make \
        && $SUDO_CMD make install
    ) \
    && rm -rf /tmp/tmux-install
}
install_wrapper "tmux" install_tmux

# neovim
install_neovim() {
    [ -d "$HOME/.local/bin/neovim-install" ] && rm -rf "$HOME/.local/bin/neovim-install"
    mkdir -p "$HOME/.local/bin/neovim-install"
    cd $HOME/.local/bin/neovim-install \
    && curl -LO https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-linux64.tar.gz \
    && tar xzvf nvim-linux64.tar.gz \
    && ln -s --force "$(realpath ./nvim-linux64/bin/nvim)" "$HOME/.local/bin/nvim"
}
exists_neovim() {
  [ -x "$(command -v nvim)" ] && nvim --version | grep -q "0.10.2"
}
install_wrapper "neovim" install_neovim exists_neovim

