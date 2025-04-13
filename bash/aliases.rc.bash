alias vim='NVIM_APPNAME="agnvim" nvim'
export EDITOR=vim

# Makes colors in CLI ls output
alias ls="ls -pF --color=auto"  # ls output with "/" for folders
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"  # ls colors

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

export GREP_COLORS='mt=1;35;40'

# Avoid duplicates
HISTCONTROL=ignoredups:erasedups
HISTFILESIZE=100000

# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend

