#!/usr/bin/env bash

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

