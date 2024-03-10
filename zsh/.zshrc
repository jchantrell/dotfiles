if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(aliases docker fzf gh git golang node npm nvm ripgrep rust ubuntu zoxide)

source $ZSH/oh-my-zsh.sh

# man pages
export MANPATH="/usr/local/man:$MANPATH"

# remote conn
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='mvim'
fi

# alias
alias python="python3"
alias v="nvim"
alias vi="nvim"
alias vim="nvim"

# go
export PATH=$PATH:/usr/local/go/bin

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH

# prettier
export PRETTIERD_DEFAULT_CONFIG="$HOME/.config/prettier/.prettierrc"

# theme
source ~/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# local
[ -f .shrc ] && source .shrc
