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
 COLOR_NONE="\[\033[0m\]"

source $DOTFILES/bash/git-prompt.inc.bash

# Set a flag that we're over SSH:
if [[ -n $SSH_CLIENT ]]; then
  prompt_user_host_name="@${HOSTNAME}"
else
  prompt_user_host_name=""
fi

# Setting prompt command to branch status
# /usr/local/etc/bash_completion.d/git-prompt.sh
source /usr/share/bash-completion/completions/git
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_SHOWCOLORHINTS=1

PROMPT_DIRTRIM=3

# Determine active Python virtualenv or conda details.
function get_virtualenv() {
    if test -z "$VIRTUAL_ENV" ; then
       echo ""
    else
       echo "${YELLOW}[`basename \"$VIRTUAL_ENV\"`]${COLOR_NONE} "
    fi
}

function get_conda_env() {
	if test -z "$CONDA_DEFAULT_ENV" ; then
       echo ""
    else
       echo "${YELLOW}[${CONDA_DEFAULT_ENV}]${COLOR_NONE} "
    fi
}

function get_err_code() {
    local EXIT="$?"

    CODE=""
    if [ $EXIT != 0 ]; then
        echo "${RED}✗${COLOR_NONE} "
    else
        echo "${LIGHT_GREEN}✓${COLOR_NONE} "
    fi
}

function middle_part() {
    # echo -e "${BLUE}\u:${WHITE}$(python ~/.short_pwd.py)${COLOR_NONE}"
    echo -e "${BLUE}\u${prompt_user_host_name}:${WHITE}\w${COLOR_NONE}"
}

function prompt_symbol() {
    echo -e  "\n${LIGHT_GREEN}➙  "
}

function __prompt_command() {
    __git_ps1 "\n$(get_err_code)$(get_virtualenv)$(get_conda_env)$(middle_part)" "$(prompt_symbol)"
}

PROMPT_COMMAND=__prompt_command
trap 'tput sgr0' DEBUG


