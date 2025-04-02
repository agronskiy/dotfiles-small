# FZF options
# colors imitate vscode ones, see
# https://github.com/tomasiser/vim-code-dark/blob/master/colors/codedark.vim
export FZF_DEFAULT_OPTS='--height 70% --reverse '\
'--color=bg+:237,bg:234,border:245,gutter:-1,'\
'fg:#D9D9D9,fg+:#D9D9D9,preview-bg:234,hl:117,hl+:75 '\
'--bind=f2:toggle-preview,'\
'page-up:preview-half-page-up,'\
'page-down:preview-half-page-down,'\
'alt-up:preview-up,'\
'alt-down:preview-down,'\
'alt-g:preview-top,'\
'alt-G:preview-bottom'

export FZF_TMUX=1
export FZF_TMUX_OPTS="-p 90%,85%"


