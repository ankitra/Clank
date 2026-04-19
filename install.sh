#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFIX="$HOME/.local"
FORCE=0
CHECK_ONLY=0
APP_NAME="clank"
SHARE_NAME="clank"
VERSION_FILE="VERSION"

usage() {
  cat <<USAGE
Usage:
  $(basename "$0") [--prefix PATH] [--force] [--check-only] [--version]

Installs the toolkit into:
  <prefix>/bin/${APP_NAME}
  <prefix>/share/${SHARE_NAME}/

Options:
  --prefix PATH   Install prefix (default: ~/.local)
  --force         Overwrite existing installed files
  --check-only    Only run environment checks; do not install
  -h, --help      Show this help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prefix)
      [[ $# -ge 2 ]] || { echo "--prefix requires a path" >&2; exit 1; }
      PREFIX="$2"
      # Validate prefix is an absolute path without dangerous elements
      case "$PREFIX" in
        /*)
          # Check for directory traversal attempts
          if [[ "$PREFIX" == *"/.."* ]] || [[ "$PREFIX" == *"../"* ]]; then
            die "Prefix must not contain directory traversal sequences (..)"
          fi
          # Check for leading dash (could be interpreted as option)
          if [[ "$PREFIX" == -* ]]; then
            die "Prefix must not start with a dash (-)"
          fi
          # Check for empty path after removing leading slash
          if [[ -z "${PREFIX#/}" ]]; then
            die "Prefix must not be just a slash"
          fi
          ;;
        *)
          die "Prefix must be an absolute path starting with /"
          ;;
      esac
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --check-only)
      CHECK_ONLY=1
      shift
      ;;
    --version|-V)
      if [[ -f "$SCRIPT_DIR/$VERSION_FILE" ]]; then
        tr -d '\r\n' < "$SCRIPT_DIR/$VERSION_FILE"
      else
        echo "unknown"
      fi
      exit 0
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

say() {
  printf '%s\n' "$*"
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

check_command() {
  command -v "$1" >/dev/null 2>&1
}

say "Checking environment..."

check_command docker || die "docker CLI not found in PATH. Install Docker Desktop or a compatible Docker CLI/runtime setup such as Colima + docker CLI."

say "- docker CLI found: $(command -v docker)"

if docker info >/dev/null 2>&1; then
  say "- docker daemon/runtime is reachable"
else
  say "- docker CLI is present, but daemon/runtime is not reachable right now"
  if check_command colima; then
    say "- colima found: $(command -v colima)"
    say "  Hint: start it with 'colima start' if that is your runtime"
  fi
  die "docker info failed"
fi

if check_command colima; then
  say "- colima found: $(command -v colima)"
  if colima status >/dev/null 2>&1; then
    say "- colima status is available"
  fi
else
  say "- colima not found (this is fine if you use Docker Desktop or another compatible runtime)"
fi

# Verify required files exist and are regular files (not symlinks) within script directory
for f in Dockerfile clank README.md .dockerignore Makefile VERSION; do
  [[ -f "$SCRIPT_DIR/$f" ]] || die "Required file missing next to installer: $f"
  # Additional security check: ensure file is not a symlink pointing outside script directory
  if [[ -L "$SCRIPT_DIR/$f" ]]; then
    die "Required file is a symlink, which is not allowed for security reasons: $f"
  fi
done

if [[ "$CHECK_ONLY" -eq 1 ]]; then
  say "Checks passed. No files installed because --check-only was used."
  exit 0
fi

BIN_DIR="$PREFIX/bin"
SHARE_DIR="$PREFIX/share/$SHARE_NAME"
TARGET="$BIN_DIR/$APP_NAME"

mkdir -p "$BIN_DIR" "$SHARE_DIR"

if [[ -e "$TARGET" && "$FORCE" -ne 1 ]]; then
  die "Target already exists: $TARGET (use --force to overwrite)"
fi

install -m 0644 "$SCRIPT_DIR/Dockerfile" "$SHARE_DIR/Dockerfile"
install -m 0644 "$SCRIPT_DIR/.dockerignore" "$SHARE_DIR/.dockerignore"
install -m 0644 "$SCRIPT_DIR/README.md" "$SHARE_DIR/README.md"
install -m 0644 "$SCRIPT_DIR/Makefile" "$SHARE_DIR/Makefile"
install -m 0644 "$SCRIPT_DIR/VERSION" "$SHARE_DIR/VERSION"
install -m 0755 "$SCRIPT_DIR/clank" "$SHARE_DIR/clank"

# Create wrapper script using printf to prevent command injection
printf '#!/usr/bin/env bash\nset -euo pipefail\nexec "%s/clank" "$@"\n' "$SHARE_DIR" > "$TARGET"
chmod 0755 "$TARGET"

say ""
say "Installed toolkit:"
say "- launcher: $TARGET"
say "- support files: $SHARE_DIR"
say ""
say "If '$BIN_DIR' is not on your PATH, add this line to your shell profile:"
say "  export PATH=\"$BIN_DIR:\$PATH\""
say ""
say "Example usage:"
say "  $APP_NAME --repo ~/claude-sandboxes/myproj"
