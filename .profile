
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
export NVC="$HOME/.config/nvim/"
export FVM_CACHE_PATH="$HOME/.fvm"
export GOPATH="$HOME/.local/share/go"
export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
export TEXMFHOME="$HOME/.local/share/texmf"
export ELECTRON_OZONE_PLATFORM_HINT=auto
export HOMEBREW_NO_ANALYTICS=1
export NVM_DIR="$HOME/.local/share/nvm"
export BUN_INSTALL="$HOME/.bun"
export VICINAE_OVERRIDES="$HOME/.config/vicinae/gpu-launch.jsonc"

prepend_path "$HOME/.local/bin"
prepend_path "$HOME/.npm-global/bin"
[ -d "$BUN_INSTALL/bin" ] && prepend_path "$BUN_INSTALL/bin"
append_path "$HOME/.cargo/bin"
append_path "$HOME/.dotnet/tools"
export PATH
