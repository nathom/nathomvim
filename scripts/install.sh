#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: install.sh [options]

Bootstrap the nathomvim config without Nix. By default, the script will
symlink the current repository into ~/.config/nathomvim, ensure portable
copies of Neovim, lazygit, and Node.js/npm are available, then run Neovim
headlessly to install lazy.nvim plugins and Mason tooling.

Options:
  --appname <name>      Override the XDG config directory name (default: nathomvim or $NVIM_APPNAME).
  --skip-link           Skip creating the ~/.config/<name> symlink.
  --check-only          Only report the symlink target and required tools.
  -h, --help            Show this help message.
USAGE
}

APPNAME="${NVIM_APPNAME:-nathomvim}"
SKIP_LINK=0
CHECK_ONLY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --appname)
      [[ $# -ge 2 ]] || { echo "Missing value for --appname" >&2; exit 1; }
      APPNAME="$2"
      shift 2
      ;;
    --skip-link)
      SKIP_LINK=1
      shift
      ;;
    --check-only)
      CHECK_ONLY=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TARGET_DIR="$CONFIG_HOME/$APPNAME"
TOOLS_DIR="${TOOLS_DIR:-$REPO_ROOT/.nathom-tools}"
BIN_DIR="$TOOLS_DIR/bin"
DEFAULT_NODE_VERSION="${DEFAULT_NODE_VERSION:-v22.11.0}"

command -v uname >/dev/null 2>&1 || { echo "uname command is required" >&2; exit 1; }

missing=()
for tool in git curl tar; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    missing+=("$tool")
  fi
done

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "Missing required tools: ${missing[*]}" >&2
  exit 1
fi

echo "Repository root: $REPO_ROOT"
echo "Config target  : $TARGET_DIR"

if [[ $SKIP_LINK -eq 0 ]]; then
  mkdir -p "$CONFIG_HOME"
  if [[ -e "$TARGET_DIR" && ! -L "$TARGET_DIR" ]]; then
    echo "Error: $TARGET_DIR already exists and is not a symlink. Remove it or re-run with --skip-link." >&2
    exit 1
  fi
  ln -snf "$REPO_ROOT" "$TARGET_DIR"
fi

if [[ $CHECK_ONLY -eq 1 ]]; then
  echo "Check-only mode: skipping Neovim bootstrap."
  exit 0
fi

mkdir -p "$BIN_DIR"
export PATH="$BIN_DIR:$PATH"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

fetch_latest_tag() {
  local repo
  repo="$1"
  if command_exists python3; then
    curl -fsSL "https://api.github.com/repos/$repo/releases/latest" | python3 -c 'import json,sys; data=json.load(sys.stdin); tag=data.get("tag_name"); print(tag or "")'
  else
    curl -fsSL "https://api.github.com/repos/$repo/releases/latest" | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name" *: *"([^"]+)".*/\1/'
  fi
}

ensure_neovim() {
  if [[ -x "$BIN_DIR/nvim" ]]; then
    NVIM_BOOTSTRAP_BIN="$BIN_DIR/nvim"
    echo "Using portable Neovim at $NVIM_BOOTSTRAP_BIN"
    return 0
  fi

  local os arch asset version url tmpdir extracted install_dir tag base
  case "$(uname -s)" in
    Linux) os="linux" ;;
    Darwin) os="macos" ;;
    *) echo "Unsupported OS for portable Neovim" >&2; return 1 ;;
  esac

  case "$(uname -m)" in
    x86_64|amd64)
      if [[ "$os" == "linux" ]]; then
        asset="nvim-linux-x86_64.tar.gz"
      else
        asset="nvim-macos-x86_64.tar.gz"
      fi
      ;;
    arm64|aarch64)
      if [[ "$os" == "linux" ]]; then
        asset="nvim-linux-arm64.tar.gz"
      else
        asset="nvim-macos-arm64.tar.gz"
      fi
      ;;
    *) echo "Unsupported CPU for portable Neovim" >&2; return 1 ;;
  esac

  tag="${NEOVIM_VERSION:-stable}"
  version="$tag"
  url="https://github.com/neovim/neovim/releases/download/${tag}/${asset}"
  tmpdir=$(mktemp -d)
  echo "Downloading Neovim ${version} (${asset})"
  if ! curl -fsSL "$url" -o "$tmpdir/$asset"; then
    echo "Failed to download Neovim archive" >&2
    rm -rf "$tmpdir"
    return 1
  fi
  tar -xzf "$tmpdir/$asset" -C "$tmpdir"
  local base="${asset%.tar.gz}"
  extracted="$tmpdir/$base"
  if [[ ! -d "$extracted" ]]; then
    echo "Neovim archive layout unexpected" >&2
    rm -rf "$tmpdir"
    return 1
  fi
  install_dir="$TOOLS_DIR/neovim/${version}/${base}"
  mkdir -p "$(dirname "$install_dir")"
  rm -rf "$install_dir"
  mv "$extracted" "$install_dir"
  ln -snf "$install_dir/bin/nvim" "$BIN_DIR/nvim"
  rm -rf "$tmpdir"
  NVIM_BOOTSTRAP_BIN="$BIN_DIR/nvim"
  echo "Installed Neovim to $install_dir"
}

fetch_latest_lazygit() {
  if command_exists python3; then
    curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest |
      python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"].lstrip("v"))'
  else
    curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest |
      grep -m1 '"tag_name"' | sed -E 's/.*"tag_name" *: *"v?([^"]+)".*/\1/'
  fi
}

ensure_lazygit() {
  if [[ -x "$BIN_DIR/lazygit" ]]; then
    echo "Using portable lazygit at $BIN_DIR/lazygit"
    return 0
  fi

  local os arch version tarball url tmpdir extracted install_dir
  case "$(uname -s)" in
    Linux) os="Linux" ;;
    Darwin) os="Darwin" ;;
    *) echo "Unsupported OS for lazygit" >&2; return 1 ;;
  esac

  case "$(uname -m)" in
    x86_64|amd64) arch="x86_64" ;;
    arm64|aarch64) arch="arm64" ;;
    *) echo "Unsupported CPU for lazygit" >&2; return 1 ;;
  esac

  version="${LAZYGIT_VERSION:-$(fetch_latest_lazygit)}"
  if [[ -z "$version" ]]; then
    echo "Unable to determine lazygit version" >&2
    return 1
  fi

  tarball="lazygit_${version}_${os}_${arch}.tar.gz"
  url="https://github.com/jesseduffield/lazygit/releases/download/v${version}/${tarball}"
  tmpdir=$(mktemp -d)
  echo "Downloading lazygit ${version} (${os}/${arch})"
  if ! curl -fsSL "$url" -o "$tmpdir/$tarball"; then
    echo "Failed to download lazygit" >&2
    rm -rf "$tmpdir"
    return 1
  fi
  tar -xzf "$tmpdir/$tarball" -C "$tmpdir"
  extracted=$(find "$tmpdir" -maxdepth 2 -type f -name lazygit -print -quit)
  if [[ -z "$extracted" ]]; then
    echo "lazygit binary not found in archive" >&2
    rm -rf "$tmpdir"
    return 1
  fi
  install_dir="$TOOLS_DIR/lazygit/v${version}"
  mkdir -p "$install_dir"
  install -m 0755 "$extracted" "$install_dir/lazygit"
  ln -snf "$install_dir/lazygit" "$BIN_DIR/lazygit"
  rm -rf "$tmpdir"
  echo "Installed lazygit to $install_dir"
}

resolve_node_version() {
  if [[ -n "${NODE_VERSION:-}" ]]; then
    printf '%s' "$NODE_VERSION"
    return
  fi
  local json version
  json=$(curl -fsSL -H 'User-Agent: nathomvim-bootstrap' https://nodejs.org/dist/index.json || true)
  if [[ -z "$json" ]]; then
    return
  fi
  if command_exists python3; then
    if ! version=$(
      PY_NODE_JSON="$json" python3 - <<'PY' 2>/dev/null
import json, os, sys
data = os.environ.get("PY_NODE_JSON")
if not data:
    sys.exit(1)
try:
    releases = json.loads(data)
except Exception:
    sys.exit(1)
for release in releases:
    if release.get("lts"):
        print(release["version"])
        break
PY
    ); then
      version=""
    fi
  fi
  if [[ -z "$version" ]]; then
    if ! version=$(printf '%s' "$json" | grep -o '"version" *: *"v[0-9.]*"' | head -n1 | sed -E 's/.*"(v[0-9.]+)".*/\1/'); then
      version=""
    fi
  fi
  [[ -n "$version" ]] && printf '%s' "$version"
}

ensure_node() {
  if [[ -x "$BIN_DIR/node" && -x "$BIN_DIR/npm" ]]; then
    echo "Using portable Node.js at $BIN_DIR/node"
    return 0
  fi

  local version os arch tarball url tmpdir dirname
  version=$(resolve_node_version)
  if [[ -z "$version" ]]; then
    version="$DEFAULT_NODE_VERSION"
    echo "Falling back to Node.js ${version}"
  fi

  case "$(uname -s)" in
    Linux) os="linux" ;;
    Darwin) os="darwin" ;;
    *) echo "Unsupported OS for Node.js" >&2; return 1 ;;
  esac

  case "$(uname -m)" in
    x86_64|amd64) arch="x64" ;;
    arm64|aarch64) arch="arm64" ;;
    *) echo "Unsupported CPU for Node.js" >&2; return 1 ;;
  esac

  tarball="node-${version}-${os}-${arch}.tar.xz"
  url="https://nodejs.org/dist/${version}/${tarball}"
  tmpdir=$(mktemp -d)
  echo "Downloading Node.js ${version} (${os}/${arch})"
  if ! curl -fsSL "$url" -o "$tmpdir/$tarball"; then
    echo "Failed to download Node.js" >&2
    rm -rf "$tmpdir"
    return 1
  fi
  mkdir -p "$TOOLS_DIR"
  tar -xJf "$tmpdir/$tarball" -C "$TOOLS_DIR"
  dirname="node-${version}-${os}-${arch}"
  if [[ ! -d "$TOOLS_DIR/$dirname" ]]; then
    echo "Extracted Node.js directory missing" >&2
    rm -rf "$tmpdir"
    return 1
  fi
  ln -snf "$TOOLS_DIR/$dirname" "$TOOLS_DIR/node-current"
  ln -snf "$TOOLS_DIR/node-current/bin/node" "$BIN_DIR/node"
  ln -snf "$TOOLS_DIR/node-current/bin/npm" "$BIN_DIR/npm"
  ln -snf "$TOOLS_DIR/node-current/bin/npx" "$BIN_DIR/npx"
  rm -rf "$tmpdir"
  echo "Installed Node.js to $TOOLS_DIR/$dirname"
}

echo "Ensuring portable Neovim, lazygit, and Node.js/npm..."
ensure_neovim || echo "Warning: failed to install Neovim"
ensure_lazygit || echo "Warning: failed to install lazygit"
ensure_node || echo "Warning: failed to install Node.js/npm"

if [[ -z "${NVIM_BOOTSTRAP_BIN:-}" ]]; then
  if command_exists nvim; then
    NVIM_BOOTSTRAP_BIN="$(command -v nvim)"
  else
    echo "Neovim binary not available" >&2
    exit 1
  fi
fi

echo "Tip: add $BIN_DIR to your PATH (e.g. export PATH=\"$BIN_DIR:\$PATH\") so the portable binaries are available in future shells."
