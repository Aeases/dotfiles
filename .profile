# Login environment (POSIX sh). Read by greetd before every session, by uwsm (which then
# exports it to systemd and D-Bus, so vicinae and other user services get it), and by zsh
# through ~/.zprofile.

prepend_path() {
  case ":$PATH:" in
    *:"$1":*) ;;
    *) PATH="$1${PATH:+:$PATH}" ;;
  esac
}
append_path() {
  case ":$PATH:" in
    *:"$1":*) ;;
    *) PATH="${PATH:+$PATH:}$1" ;;
  esac
}

export EDITOR=nvim
export VISUAL=nvim
export BROWSER=nvim:vim:nano:firefox
export NVC="$HOME/.config/nvim/"
export FVM_CACHE_PATH="$HOME/.fvm"
export GOPATH="$HOME/.local/share/go"
export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
export TEXMFHOME="$HOME/.local/share/texmf"
export ELECTRON_OZONE_PLATFORM_HINT=auto
export HOMEBREW_NO_ANALYTICS=1
export NVM_DIR="$HOME/.nvm"
export BUN_INSTALL="$HOME/.bun"

prepend_path "$HOME/.local/bin"
prepend_path "$HOME/.npm-global/bin"
[ -d "$BUN_INSTALL/bin" ] && prepend_path "$BUN_INSTALL/bin"
append_path "$HOME/.cargo/bin"
append_path "$HOME/.dotnet/tools"
export PATH

unset -f prepend_path append_path
