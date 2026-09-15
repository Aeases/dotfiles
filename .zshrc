# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

eval "$(dircolors -b)"
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history # Persist history
HISTSIZE=1000000
SAVEHIST=1000000
setopt autocd autopushd pushdminus pushdsilent pushdtohome
setopt SHARE_HISTORY
# setopt INC_APPEND_HISTORY # Not needed with SHARE_HISTORY
unsetopt correct_all BEEP # Disable Autocorrect

# DIV: > Compinit Setup <
autoload -Uz compinit
zstyle ':completion:*' menu select # Tab goes into the list of options.
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} # Color-coded completions
zmodload zsh/complist

# only runs the full compinit once every 24hrs. uses cached compinit otherwise.
# needs EXTENDED_GLOB for (#qN.mh+24) to work.
setopt EXTENDED_GLOB
if [[ -n "${HOME}/.zcompdump"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
_comp_options+=(globdots) # Ensure hidden files are listed in completions
zle_highlight=('paste:none') # Disable highlighting pasted text

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

# source zprofile for non-login
[[ -o login ]] || source "${HOME}/.zprofile"

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
zinit load zdharma-continuum/history-search-multi-word
zinit light zsh-users/zsh-completions
zinit light hlissner/zsh-autopair
#zinit light marlonrichert/zsh-autocomplete
zinit light zsh-users/zsh-autosuggestions
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *|ls *|zd *|xdg-open *|nautilus *|open *"
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8,underline"
zinit light zdharma-continuum/fast-syntax-highlighting

prepend_path "$HOME/bin"
prepend_path "$HOME/.local/bin"
append_path "$HOME/.scripts"

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

append_path "$HOME/.spicetify"

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
[[ ! -r "$HOME/.opam/opam-init/init.zsh" ]] || source "$HOME/.opam/opam-init/init.zsh" > /dev/null 2> /dev/null
# END opam configuration

# >>> fnm initialize (lazy-loaded: real init deferred until first node/npm/npx/corepack/fnm call, saves ~28ms/shell) >>>
# node/npm/npx also exist as system binaries, so each must be wrapped individually rather than
# relying on a missing-command fallback, or you'd silently run the wrong (system) version.
_fnm_lazy_load() {
  unfunction node npm npx corepack fnm 2>/dev/null
  eval "$(fnm env --use-on-cd --shell zsh)"
}
for _fnm_cmd in node npm npx corepack fnm; do
  eval "${_fnm_cmd}() { _fnm_lazy_load; command ${_fnm_cmd} \"\$@\" }"
done
unset _fnm_cmd
# <<< fnm initialize <<<

# >>> conda initialize (lazy-loaded: real init deferred until first `conda` call, saves ~500ms/shell) >>>
conda() {
    unfunction conda
    __conda_setup="$('/home/zane/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/home/zane/miniconda3/etc/profile.d/conda.sh" ]; then
            . "/home/zane/miniconda3/etc/profile.d/conda.sh"
        else
            export PATH="/home/zane/miniconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup
    conda "$@"
}
# <<< conda initialize <<<

# Pins prompt to bottom of screen if kitty launched with env KITTY_SCRATCHPAD
if [[ -n $KITTY_SCRATCHPAD ]]; then
	autoload -Uz add-zsh-hook

	keep_prompt_at_bottom() {
		print -n '\e[999;1H'
	}

	add-zsh-hook precmd keep_prompt_at_bottom
fi
