# Number of things is stored in this repo.
export PATH=$DOTFILES/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export TMUX_TMPDIR=$HOME/.tmux-tmp-dir

# Set TERMINFO for statically linked tmux to find terminfo database
# Try common system terminfo locations
if [ -z "$TERMINFO" ]; then
    if [ -d "/usr/share/terminfo" ]; then
        export TERMINFO=/usr/share/terminfo
    elif [ -d "/etc/terminfo" ]; then
        export TERMINFO=/etc/terminfo
    elif [ -d "/usr/lib/terminfo" ]; then
        export TERMINFO=/usr/lib/terminfo
    fi
fi

