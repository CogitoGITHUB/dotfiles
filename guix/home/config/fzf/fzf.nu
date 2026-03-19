# FZF Colors - White theme with dark red accents
# Colors: #8B0000 (dark red), #A52A2A (light red), #FFFFFF (white)

export FZF_DEFAULT_COMMAND='fzf --color=bg+:#FFFFFF,bg:#FFFFFF,spinner:#8B0000,hl:#8B0000,fg:#8B0000,header:#8B0000,info:#A52A2A,pointer:#8B0000,marker:#8B0000,fg+:#8B0000,prompt:#8B0000,hl+:#8B0000'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_DEFAULT_OPTS='
  --color=bg+:#FFFFFF,bg:#FFFFFF,spinner:#8B0000,hl:#8B0000,fg:#8B0000,header:#8B0000,info:#A52A2A,pointer:#8B0000,marker:#8B0000,fg+:#8B0000,prompt:#8B0000,hl+:#8B0000
  --highlight-line=#FFFFFF
  --layout=reverse
  --border=rounded
'
