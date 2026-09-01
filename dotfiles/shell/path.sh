# Shared PATH setup for Bash and Zsh. Keep this file POSIX-compatible.

path_prepend() {
  case ":${PATH:-}:" in
    *":$1:"*) ;;
    *) PATH="$1${PATH:+:$PATH}" ;;
  esac
}

path_append() {
  case ":${PATH:-}:" in
    *":$1:"*) ;;
    *) PATH="${PATH:+$PATH:}$1" ;;
  esac
}

# Prepend lower-priority locations first.
path_prepend "/usr/local/bin"
path_prepend "/usr/local/sbin"
path_prepend "/opt/local/bin"
path_prepend "/opt/local/sbin"
path_prepend "/opt/homebrew/bin"
path_prepend "$HOME/.config/yarn/global/node_modules/.bin"
path_prepend "$HOME/.yarn/bin"
path_prepend "$HOME/.npm-global/bin"

export GOPATH="${GOPATH:-$HOME/go}"
path_prepend "$GOPATH/bin"
if [ -n "${GOROOT:-}" ]; then
  path_prepend "$GOROOT/bin"
fi

path_prepend "$HOME/.cargo/bin"
path_prepend "$HOME/bin"
path_prepend "$HOME/config/bin"
path_prepend "$HOME/.local/bin"

# These were historically lower-priority PATH entries.
path_append "$HOME/bin/zig"
path_append "$HOME/Library/Python/3.8/bin"

export PATH
unset -f path_prepend path_append 2>/dev/null || true
