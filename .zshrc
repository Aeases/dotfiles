# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [ -n "$HOME" ]; then
  [ -d "$HOME/.local/bin" ] && append_path "$HOME/.local/bin"
  [ -d "$HOME/bin" ] && append_path "$HOME/bin"
fi
eval "$(dircolors -b)"
eval "$(fnm env --use-on-cd)"
INC_APPEND_HISTORY="true"
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history # Persist history
HISTSIZE=1000000
SAVEHIST=1000000
setopt appendhistory autocd autopushd pushdminus pushdsilent pushdtohome
setopt SHARE_HISTORY

# DIV: > Compinit Setup <
autoload -Uz compinit
zstyle ':completion:*' menu select # Tab goes into the list of options.
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} # Color-coded completions
zmodload zsh/complist
compinit
_comp_options+=(globdots) # Ensure hidden files are listed in completions
zle_highlight=('paste:none') # Disable highlighting pasted text
unsetopt correct_all BEEP # Disable Autocorrect
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
# lfcd () {cd "$(command lf -print-last-dir "$@")"}
function yazicd() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
bindkey -s '^[o' 'yazicd\n' 
source "${HOME}/.zprofile"

DHOME=$HOME/dotfiles
# Plugins manager
ZINIT_HOME="${HOME}/.config/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

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
zinit light hlissner/zsh-autopair
#zinit light marlonrichert/zsh-autocomplete
zinit light zsh-users/zsh-autosuggestions
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *|ls *|zd *|xdg-open *|nautilus *|open *"
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8,underline"
zinit light zdharma/fast-syntax-highlighting

source "${HOME}/.scriptsyFripsy.bash"
source "${HOME}/.apikeys"

# OS specific scripts
if [ Linux = `uname` ]; then
  source "${HOME}/.profile-linux"
fi

if [ Darwin = `uname` ]; then
  source "${HOME}/.profile-macos"
fi

eval "$(zoxide init zsh --cmd zd)"

export PATH=$PATH:$HOME/.spicetify

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f "$HOME/.dart-cli-completion/zsh-config.zsh" ]] && . "$HOME/.dart-cli-completion/zsh-config.zsh" || true
## [/Completion]

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '$HOME/.opam/opam-init/init.zsh' ]] || source '$HOME/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration
