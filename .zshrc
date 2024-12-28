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
a
# DIV: > Compinit Setup <
autoload -Uz compinit
zstyle ':completion:*' menu select # Tab goes into the list of options.
zmodload zsh/complist
compinit
_comp_options+=(globdots) # Ensure hidden files are listed in completions
zle_highlight=('paste:none') # Disable highlighting pasted text
unsetopt correct_all BEEP # Disable Autocorrect
fkgjfkg
# DIV: >>> MY CUSTOM KEYBINDS <<<

# Makes Ctrl+a accept zsh completions
bindkey '^[a' autosuggest-accept 

# Edit line in vim buffer
autoload -U edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# vi mode (NOT NEEDED WITH VI MODE PLUGIN)
# bindkey -v
# export KEYTIMEOUT=1

# Use vim keybinds to select stuff in the autocomplete menujk
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Opens lfcd on alt+o
lfcd () {cd "$(command lf -print-last-dir "$@")"}
bindkey -s '^[o' 'lfcd\n' 


source "${HOME}/.zprofile"

DHOME=$HOME/dotfiles
# Plugins manager
ZINIT_HOME="${HOME}/.config/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Ensure tpm is installed
TMUX_PLUGIN_MANAGER_PATH="${DHOME}/.config/tmux/plugins"
TMUX_TPM="${TMUX_PLUGIN_MANAGER_PATH}/tpm"
# TODO: Make tmux check if ANY folder from the plugins directory is entirely empty, if so rmdir it, and do a plugin install.
if [[ -z "$(ls -A $TMUX_TPM)" ]]; then
  echo "Tmux Plugin Manager is not installed, installing now."
  rmdir ${TMUX_PLUGIN_MANAGER_PATH}/*
  git clone https://github.com/tmux-plugins/tpm $TMUX_TPM && $TMUX_TPM/tpm && $TMUX_TPM/bin/install_plugins
fi


# DIV: ZINIT STUFF

# Load powerlevel10k theme
zinit ice depth"1" # git clone depth
zinit light romkatv/powerlevel10k
zinit light jeffreytse/zsh-vi-mode
# Load pure theme
# zinit ice pick"async.zsh" src"pure.zsh" # with zsh-async library that's bundled with it.
# zinit light sindresorhus/pure
zinit load zdharma/history-search-multi-word
zinit light zsh-users/zsh-completions
#zinit light marlonrichert/zsh-autocomplete
zinit light zsh-users/zsh-autosuggestions
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *|ls *|zd *|xdg-open *|nautilus *|open *"
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8,underline"
zinit light zdharma/fast-syntax-highlighting

source "${HOME}/.scriptsyFripsy.bash"


# Platform specific scripts
if [ Linux = `uname` ]; then
  source "${HOME}/.profile-linux"
  source "${HOME}/.config/wezterm/wezterm.sh"
  # WARNING: ^^^^ if i ever use mac, A: be ashamed, B: add this to the profile-mac too.
fi

if [ Darwin = `uname` ]; then
  source "${HOME}/.profile-macos"
fi

eval "$(zoxide init zsh --cmd zd)"

export PATH=$PATH:/var/home/aeases/.spicetify

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PATH=$PATH:/var/home/zane/.spicetify

# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
#         . "/opt/miniconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="/opt/miniconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<

