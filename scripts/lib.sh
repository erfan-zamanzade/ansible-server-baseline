# Shared helpers for the scripts in this directory. Source it, don't execute it.
# shellcheck shell=bash

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export REPO_ROOT

# shellcheck source=scripts/versions.sh
source "$REPO_ROOT/scripts/versions.sh"

# Everything lives inside the repository: the Python virtualenv, uv and the
# Ansible collections. Nothing is installed system-wide.
export PATH="$REPO_ROOT/.venv/bin:$REPO_ROOT/.tools/bin:$PATH"
export UV_CACHE_DIR="$REPO_ROOT/.tools/uv-cache"
export ANSIBLE_CONFIG="$REPO_ROOT/ansible.cfg"
export ANSIBLE_COLLECTIONS_PATH="$REPO_ROOT/collections"
export ANSIBLE_ROLES_PATH="$REPO_ROOT/roles"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*" >&2; }
ok() { printf '\033[1;32m  ✓\033[0m %s\n' "$*" >&2; }
fail() { printf '\033[1;31m  ✗\033[0m %s\n' "$*" >&2; exit 1; }
