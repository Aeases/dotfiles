# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

DISABLE_AUTO_TITLE="true" # Disable auto-setting terminal title.
COMPLETION_WAITING_DOTS="true" # Display red dots whilst waiting for completion.
DISABLE_UNTRACKED_FILES_DIRTY="true" # Disable marking untracked files
INC_APPEND_HISTORY="true"
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history # Persist history
HISTSIZE=1000000
SAVEHIST=1000000
setopt appendhistory autocd autopushd pushdminus pushdsilent pushdtohome
# Disable highlighting pasted text
zle_highlight=('paste:none')
# Disable Autocorrect
unsetopt correct_all BEEP

DHOME=$HOME/dotfiles/
# Plugins manager
ZINIT_HOME="${HOME}/.config/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Ensure tpm is installed
TMUX_PLUGIN_MANAGER_PATH="${DHOME}/.config/tmux/plugins"
TMUX_TPM="${TMUX_PLUGIN_MANAGER_PATH}/tpm"
if [[ -z "$(ls -A $TMUX_TPM)" ]]; then
  echo "Tmux Plugin Manager is not installed, installing now."
  rmdir ${TMUX_PLUGIN_MANAGER_PATH}/*
  git clone https://github.com/tmux-plugins/tpm $TMUX_TPM && $TMUX_TPM/tpm && $TMUX_TPM/bin/install_plugins
  # "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"
fi

# Init Completions
autoload -Uz compinit
compinit
# Load powerlevel10k theme
zinit ice depth"1" # git clone depth
zinit light romkatv/powerlevel10k

# Load pure theme
zinit ice pick"async.zsh" src"pure.zsh" # with zsh-async library that's bundled with it.
zinit light sindresorhus/pure

zinit load zdharma/history-search-multi-word
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma/fast-syntax-highlighting

if [ Linux = `uname` ]; then
  source "${HOME}/.profile-linux"
fi

if [ Darwin = `uname` ]; then
  source "${HOME}/.profile-macos"
fi


alias open=xdg-open
alias l='ls -la'


. "$HOME/.cargo/env"
export PATH=$PATH:/var/home/aeases/.spicetify

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
