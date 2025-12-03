#!/usr/bin/env bash

# Detect architecture
# Note: Different versions used per architecture due to availability:
# - ripgrep 13.0.0 lacks aarch64 support, using 15.1.0 for aarch64
# - neovim v0.10.2 lacks aarch64 tar.gz, using v0.11.5 for aarch64
ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64)
        ARCH_SUFFIX="amd64"
        ARCH_RIPGREP="x86_64-unknown-linux-musl"
        ARCH_NVIM="linux64"
        RIPGREP_VERSION="13.0.0"
        NVIM_VERSION="v0.10.2"
        NVIM_VERSION_CHECK="0.10.2"
        ;;
    aarch64|arm64)
        ARCH_SUFFIX="aarch64"
        ARCH_RIPGREP="aarch64-unknown-linux-gnu"
        ARCH_NVIM="linux-arm64"
        RIPGREP_VERSION="15.1.0"
        NVIM_VERSION="v0.11.5"
        NVIM_VERSION_CHECK="0.11.5"
        ;;
    *)
        echo "Unsupported architecture: $ARCH" >&2
        exit 1
        ;;
esac

# tmux: Uses pre-built binaries from local repo (tmux doesn't provide official binaries)
# Note: Requires tmux.linux-${ARCH_SUFFIX}.tar.gz to exist in $DOTFILES/tmux/
# Note: Statically linked tmux needs TERMINFO to find terminfo database
install_tmux() {
    [ -d "$HOME/.local/bin/tmux-install" ] && rm -rf "$HOME/.local/bin/tmux-install"
    mkdir -p "$HOME/.local/bin/tmux-install"
    TMUX_ARCHIVE="tmux.linux-${ARCH_SUFFIX}.tar.gz"
    TMUX_DIR="tmux.linux-${ARCH_SUFFIX}"
    if [ -f "$DOTFILES/tmux/$TMUX_ARCHIVE" ]; then
        (
            cd $HOME/.local/bin/tmux-install \
            && cp "$DOTFILES/tmux/$TMUX_ARCHIVE" . \
            && tar -xvf "$TMUX_ARCHIVE" \
            && ln -s --force "$(realpath ./$TMUX_DIR)" "$HOME/.local/bin/tmux"
        )
    else
        echo "Error: tmux binary archive not found: $DOTFILES/tmux/$TMUX_ARCHIVE" >&2
        exit 1
    fi
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
    RIPGREP_ARCHIVE="ripgrep-${RIPGREP_VERSION}-${ARCH_RIPGREP}.tar.gz"
    RIPGREP_DIR="ripgrep-${RIPGREP_VERSION}-${ARCH_RIPGREP}"
    cd $HOME/.local/bin/ripgrep-install \
    && curl -LO "https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/${RIPGREP_ARCHIVE}" \
    && tar xzvf "$RIPGREP_ARCHIVE" \
    && ln -s --force "$(realpath ./${RIPGREP_DIR}/rg)" "$HOME/.local/bin/rg"
}
exists_ripgrep() {
    [ -x "$(command -v rg)" ]
}
install_wrapper "ripgrep" install_ripgrep exists_ripgrep

# fzf: Built from source, architecture-agnostic
install_fzf() {
    rm -rf "$HOME/.fzf" || true
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" \
        && "$HOME/.fzf/install" --key-bindings --completion --no-update-rc
}
exists_fzf() {
    [ -x "$HOME/.fzf/bin/fzf" ]
}
install_wrapper "fzf" install_fzf exists_fzf

# fzf tab compl
install_fzf_tab_completion() {
    rm -rf "$HOME/.fzf-tab-completion" || true
    git clone --depth 1 https://github.com/agronskiy/fzf-tab-completion.git "$HOME/.fzf-tab-completion"
}
exists_fzf_tab_completion() {
    [ -d $HOME/.fzf-tab-completion/.git ]
}
install_wrapper "fzf_tab_completion" install_fzf_tab_completion exists_fzf_tab_completion

# neovim
# this installer assumes all the lazy installations into `agnvim` appname to avoid
# clashes with other installs
install_neovim() {
    [ -d "$HOME/.local/bin/neovim-install" ] && rm -rf "$HOME/.local/bin/neovim-install"
    mkdir -p "$HOME/.local/bin/neovim-install"
    NVIM_ARCHIVE="nvim-${ARCH_NVIM}.tar.gz"
    NVIM_DIR="nvim-${ARCH_NVIM}"
    cd $HOME/.local/bin/neovim-install \
    && curl -LO "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${NVIM_ARCHIVE}" \
    && tar xzvf "$NVIM_ARCHIVE" \
    && ln -s --force "$(realpath ./${NVIM_DIR}/bin/nvim)" "$HOME/.local/bin/nvim" \
    && NVIM_APPNAME='agnvim' $HOME/.local/bin/nvim --headless '+Lazy! install' +qa
}
exists_neovim() {
  [ -x "$(command -v nvim)" ] && nvim --version | grep -q "${NVIM_VERSION_CHECK}"
}
install_wrapper "neovim" install_neovim exists_neovim

