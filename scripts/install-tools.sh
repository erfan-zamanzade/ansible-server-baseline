#!/usr/bin/env bash
# Install the pinned toolchain into the repository: uv (checksum verified), a
# Python virtualenv synced from requirements.txt (every package hash-checked),
# and the Ansible collections from requirements.yml.
set -euo pipefail
# shellcheck source=scripts/lib.sh
source "$(dirname "$0")/lib.sh"

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64 | aarch64) ;;
  *) fail "unsupported architecture $ARCH" ;;
esac

if [[ "$(uv --version 2>/dev/null)" != "uv $UV_VERSION"* ]]; then
  work="$(mktemp -d)"
  trap 'rm -rf "$work"' EXIT
  sha_var="UV_SHA256_${ARCH}"
  curl --fail --silent --show-error --location --retry 3 -o "$work/uv.tgz" \
    "https://github.com/astral-sh/uv/releases/download/$UV_VERSION/uv-$ARCH-unknown-linux-gnu.tar.gz"
  echo "${!sha_var}  $work/uv.tgz" | sha256sum --check --quiet - || fail "checksum mismatch for uv"
  tar -xzf "$work/uv.tgz" -C "$work"
  mkdir -p "$REPO_ROOT/.tools/bin"
  install -m 0755 "$work/uv-$ARCH-unknown-linux-gnu/uv" "$REPO_ROOT/.tools/bin/uv"
fi
ok "uv $UV_VERSION"

[[ -x "$REPO_ROOT/.venv/bin/python" ]] || uv venv --quiet --python 3.12 "$REPO_ROOT/.venv"
uv pip sync --quiet --python "$REPO_ROOT/.venv" --require-hashes "$REPO_ROOT/requirements.txt"
ok "Python tools: $(ansible --version | head -1), molecule $(molecule --version | awk '{print $2; exit}')"

ansible-galaxy collection install --upgrade -r "$REPO_ROOT/requirements.yml" -p "$REPO_ROOT/collections" >/dev/null
ok "collections: $(ansible-galaxy collection list -p "$REPO_ROOT/collections" 2>/dev/null | awk '/^[a-z]+\.[a-z_]+ /{printf "%s %s  ", $1, $2}')"
