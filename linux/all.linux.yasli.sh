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

# tmux-tpm
install_tmux_tpm() {
    mkdir -p $HOME/.tmux/plugins
    git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

    # In some HPC environments, we actually don't want to try and run tmux already here,
    # because this sometimes interferes with comples ssh-ing schemas from login nodes to compute nodes
    # (and even more complex -- with runnign dockers inside those). So we let the actual installation happen when the user
    # first actually runs tmux via <prefix> shift-I, see `tmux.conf`.
    # && TMUX_PLUGIN_MANAGER_PATH=$HOME/.tmux/plugins /$HOME/.tmux/plugins/tpm/bin/install_plugins
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

# fzf
install_fzf() {
    rm -rf "$HOME/.fzf" || true
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" \
        && "$HOME/.fzf/install" --key-bindings --completion --no-update-rc
}
exists_fzf() {
    [ -x "$HOME/.fzf/bin/fzf" ]
}
install_wrapper "fzf" install_fzf exists_fzf

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

