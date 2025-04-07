#!/usr/bin/env bash

install_tmux() {
    [ -d "$HOME/.local/bin/tmux-install" ] && rm -rf "$HOME/.local/bin/tmux-install"
    mkdir -p "$HOME/.local/bin/tmux-install"
    (
        cd $HOME/.local/bin/tmux-install \
        && cp $DOTFILES/tmux/tmux.linux-amd64.tar.gz . \
        && tar -xvf tmux.linux-amd64.tar.gz \
        && ln -s --force "$(realpath ./tmux.linux-amd64)" "$HOME/.local/bin/tmux"
    )
}
exists_tmux() {
  [ -x "$(command -v tmux)" ] && tmux -V | grep -q "3.5"
}
install_wrapper "tmux" install_tmux exists_tmux

install_tmux_tpm() {
    mkdir -p $HOME/.tmux/plugins
    git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm \
        && TMUX_PLUGIN_MANAGER_PATH=$HOME/.tmux/plugins /$HOME/.tmux/plugins/tpm/bin/install_plugins
}
exists_tmux_tpm () {
    [ -d $HOME/.tmux/plugins/tpm/.git ]
}
update_tmux_tpm () {
    ( cd $HOME/.tmux/plugins/tpm && git pull &> /dev/null )
}
install_wrapper "tmux tpm" \
    install_tmux_tpm \
    exists_tmux_tpm \
    update_tmux_tpm

