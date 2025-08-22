
#command for switching default audio track in mkv
#for i in ./*; do mkvpropedit $i --edit track:a1 --set flag-default=0 --edit track:a2 --set flag-default=1; done
#command for disabling signs and songs
alias v="nvim"
# MPV but it plays two audio tracks simultaneously
alias open=xdg-open
alias daa="cd ~/Documents/Engram/University/DAA・COMP3001/"
alias ia="cd ~/Dev/Uni/IA/Assignment3/"
alias china="cd ~/Documents/Engram/Resources/Chinese/"
alias hcf='cd ~/.config/hypr/'
alias eng='cd ~/Documents/Engram/'
alias dun='cd ~/Dev/Uni/'
alias prep='cd ~/repos/asbplayer/scripts/web-socket-server/; go run main.go & anki'
alias nvide="neovide"
alias watchtex='function _watchtex(){ while inotifywait -e close_write "$1"; do pdflatex "$1"; done }; _watchtex'

# Convert audio of any file to mp3, I use for mkv's that come encoded in a audio format chrome cannot read.
function convertaudio() {
  ffmpeg -i $1 -c:v copy -c:a mp3 -ab 192k /tmp/$1 && mv /tmp/$1 $1
}

alias nv="neovide"
#alias venv="python -m venv"
# source "${HOME}/.zprofilebruh"
alias lg="lazygit"
alias gst="git status"
#alias host="distrobox-host-exec bash"
alias l='ls -la'
alias o='open'
alias dart="dart --disable-analytics"
#alias fixgpu="sudo cat /sys/kernel/debug/dri/1/amdgpu_gpu_recover"
alias fixspicetify="sudo chmod a+wr /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify; sudo chmod a+wr /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify"
alias userctl="systemctl --user"
alias refreshWaybar="pkill waybar && hyprctl dispatch exec waybar"
alias watchmeboogie="while true; do make -q || make; sleep 0.5; done"
alias was-watch='cargo watch -i .gitignore -i "pkg/*" -s "wasm-pack build"'
alias d2b='python ~/Dev/Uni/PDI/binaryConversion.py -d2b'


lwhich () { which $1 | xargs dirname | xargs eza --color=always -l | grep $1 }
if which eza > /dev/null 2>&1; then
  alias ls="eza --icons=auto"
fi
if which bat > /dev/null 2>&1; then
  alias cat="bat -pp"
fi

ncd ()
{
    # Block nesting of nnn in subshells
    [ "${NNNLVL:-0}" -eq 0 ] || {
        echo "nnn is already running"
        return
    }

    # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
    # If NNN_TMPFILE is set to a custom path, it must be exported for nnn to
    # see. To cd on quit only on ^G, remove the "export" and make sure not to
    # use a custom path, i.e. set NNN_TMPFILE *exactly* as follows:
    #      NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
    # stty start undef
    # stty stop undef
    # stty lwrap undef
    # stty lnext undef

    # The command builtin allows one to alias nnn to n, if desired, without
    # making an infinitely recursive alias
    command nnn -Eac "$@"

    [ ! -f "$NNN_TMPFILE" ] || {
        . "$NNN_TMPFILE"
        rm -f -- "$NNN_TMPFILE" > /dev/null
    }
}


gifMe () {mkdir -p /tmp/gifMeImages/; rm /tmp/gifMeImages/*.png; ffmpeg -i $1 -vf scale=320:-1 -r 30 /tmp/gifMeImages/ffout%3d.png && magick convert -delay 2 -loop 0 /tmp/gifMeImages/ffout*.png ./${1:t:r}.gif; }
# ZSH-autcomplete settings
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#d19a66"

# Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Add installed bun binaries to path
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH



export HOMEBREW_NO_ANALYTICS=1






# DIV: >>> ZSH KEYBINDS STOLEN FROM OMZ <<< 
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() {
    echoti smkx
  }
  function zle-line-finish() {
    echoti rmkx
  }
  zle -N zle-line-init
  zle -N zle-line-finish
fi

### Terminal Keybinds!


# Stolen from oh my zsh below;

# Use emacs key bindings
# bindkey -e

# [PageUp] - Up a line of history
if [[ -n "${terminfo[kpp]}" ]]; then
  bindkey -M emacs "${terminfo[kpp]}" up-line-or-history
  bindkey -M viins "${terminfo[kpp]}" up-line-or-history
  bindkey -M vicmd "${terminfo[kpp]}" up-line-or-history
fi
# [PageDown] - Down a line of history
if [[ -n "${terminfo[knp]}" ]]; then
  bindkey -M emacs "${terminfo[knp]}" down-line-or-history
  bindkey -M viins "${terminfo[knp]}" down-line-or-history
  bindkey -M vicmd "${terminfo[knp]}" down-line-or-history
fi

# Start typing + [Up-Arrow] - fuzzy find history forward
if [[ -n "${terminfo[kcuu1]}" ]]; then
  autoload -U up-line-or-beginning-search
  zle -N up-line-or-beginning-search

  bindkey -M emacs "${terminfo[kcuu1]}" up-line-or-beginning-search
  bindkey -M viins "${terminfo[kcuu1]}" up-line-or-beginning-search
  bindkey -M vicmd "${terminfo[kcuu1]}" up-line-or-beginning-search
fi
# Start typing + [Down-Arrow] - fuzzy find history backward
if [[ -n "${terminfo[kcud1]}" ]]; then
  autoload -U down-line-or-beginning-search
  zle -N down-line-or-beginning-search

  bindkey -M emacs "${terminfo[kcud1]}" down-line-or-beginning-search
  bindkey -M viins "${terminfo[kcud1]}" down-line-or-beginning-search
  bindkey -M vicmd "${terminfo[kcud1]}" down-line-or-beginning-search
fi

# [Home] - Go to beginning of line
if [[ -n "${terminfo[khome]}" ]]; then
  bindkey -M emacs "${terminfo[khome]}" beginning-of-line
  bindkey -M viins "${terminfo[khome]}" beginning-of-line
  bindkey -M vicmd "${terminfo[khome]}" beginning-of-line
fi
# [End] - Go to end of line
if [[ -n "${terminfo[kend]}" ]]; then
  bindkey -M emacs "${terminfo[kend]}"  end-of-line
  bindkey -M viins "${terminfo[kend]}"  end-of-line
  bindkey -M vicmd "${terminfo[kend]}"  end-of-line
fi

# [Shift-Tab] - move through the completion menu backwards
if [[ -n "${terminfo[kcbt]}" ]]; then
  bindkey -M emacs "${terminfo[kcbt]}" reverse-menu-complete
  bindkey -M viins "${terminfo[kcbt]}" reverse-menu-complete
  bindkey -M vicmd "${terminfo[kcbt]}" reverse-menu-complete
fi



# [Backspace] - delete backward
bindkey -M emacs '^?' backward-delete-char
bindkey -M viins '^?' backward-delete-char
bindkey -M vicmd '^?' backward-delete-char
# [Delete] - delete forward
if [[ -n "${terminfo[kdch1]}" ]]; then
  bindkey -M emacs "${terminfo[kdch1]}" delete-char
  bindkey -M viins "${terminfo[kdch1]}" delete-char
  bindkey -M vicmd "${terminfo[kdch1]}" delete-char
else
  bindkey -M emacs "^[[3~" delete-char
  bindkey -M viins "^[[3~" delete-char
  bindkey -M vicmd "^[[3~" delete-char

  bindkey -M emacs "^[3;5~" delete-char
  bindkey -M viins "^[3;5~" delete-char
  bindkey -M vicmd "^[3;5~" delete-char
fi



export WORDCHARS='*?_-[]~&;!#$%^(){}<>'


# [Ctrl-Delete] - delete whole forward-word
bindkey -M emacs '^[[3;5~' kill-word
bindkey -M viins '^[[3;5~' kill-word
bindkey -M vicmd '^[[3;5~' kill-word

# [Ctrl-RightArrow] - move forward one word
bindkey -M emacs '^[[1;5C' forward-word
bindkey -M viins '^[[1;5C' forward-word
bindkey -M vicmd '^[[1;5C' forward-word
# [Ctrl-LeftArrow] - move backward one word
bindkey -M emacs '^[[1;5D' backward-word
bindkey -M viins '^[[1;5D' backward-word
bindkey -M vicmd '^[[1;5D' backward-word


bindkey '\ew' kill-region                             # [Esc-w] - Kill from the cursor to the mark
bindkey -s '\el' 'ls\n'                               # [Esc-l] - run command: ls
bindkey '^r' history-incremental-search-backward      # [Ctrl-r] - Search backward incrementally for a specified string. The string may begin with ^ to anchor the search to the beginning of the line.
bindkey ' ' magic-space                               # [Space] - don't do history expansion



# file rename magick
bindkey "^[m" copy-prev-shell-word
