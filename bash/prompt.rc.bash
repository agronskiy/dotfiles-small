# Check https://unix.stackexchange.com/questions/124407/what-color-codes-can-i-use-in-my-ps1-prompt
# for more colors codes
        RED="\[\033[0;31m\]"
     YELLOW="\[\033[1;33m\]"
      GREEN="\[\033[0;32m\]"
       BLUE="\[\033[1;34m\]"
  LIGHT_RED="\[\033[1;31m\]"
LIGHT_GREEN="\[\033[1;32m\]"
 LIGHT_BLUE="\[\033[38;5;81m\]"
      WHITE="\[\033[1;37m\]"
 LIGHT_GRAY="\[\033[0;37m\]"
 RESET="\[\033[0m\]"

# See git-prompt
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_SHOWCOLORHINTS=1
source $DOTFILES/bash/git-prompt.inc.bash

# Set a flag that we're over SSH:
if [[ -n $SSH_CLIENT ]]; then
  prompt_user_host_name="@${HOSTNAME}"
else
  prompt_user_host_name=""
fi

PROMPT_DIRTRIM=3
# Determine active Python virtualenv details.
function get_virtualenv() {
    if ! test -z "$VIRTUAL_ENV" ; then
        echo "${YELLOW}(`basename \"$VIRTUAL_ENV\"`)${RESET} "
    fi
    if ! test -z "$CONDA_DEFAULT_ENV" ; then
        echo "${YELLOW}(`basename \"$CONDA_DEFAULT_ENV\"`)${RESET} "
    fi
}

function get_err_code() {
    local EXIT_CODE=$?
    echo -e ${EXIT_CODE}
}

# Unused
function display_err_code() {
    local EXIT_CODE=$1
    if [[ $EXIT_CODE -ne 0 ]]; then
        echo "${LIGHT_RED}[✘]${RESET} "
    else
        echo "${LIGHT_GREEN}[✔]${RESET} "
    fi
}

function middle_part() {
    # echo -e "${BLUE}\u:${WHITE}$(python ~/.short_pwd.py)${COLOR_NONE}"
    echo -e "${LIGHT_BLUE}\u@${HOSTNAME}:${WHITE}\w${COLOR_NONE}"
}

function prompt_symbol() {
    local EXIT_CODE=$1

    if [[ $EXIT_CODE -ne 0 ]]; then
        local color="${LIGHT_RED}"
    else
        local color="${LIGHT_GREEN}"
    fi
    echo -e  "\n${color}❱ ${RESET}"
}

function precmd() {
    local EXIT_CODE=$(get_err_code)
    # Add $(display_err_code ${EXIT_CODE}) if needed more visual
    __git_ps1   "${NEWLINE}$(get_virtualenv)$(middle_part)"\
                "$(prompt_symbol ${EXIT_CODE})"
}

PROMPT_COMMAND=precmd
trap 'tput sgr0' DEBUG


# Avoid random percent sign.
# See https://unix.stackexchange.com/questions/167582/why-zsh-ends-a-line-with-a-highlighted-percent-symbol
export PROMPT_EOL_MARK=''


