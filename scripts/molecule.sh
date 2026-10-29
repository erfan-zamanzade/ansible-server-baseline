#!/usr/bin/env bash
# Run a Molecule scenario against one distribution:
#   scripts/molecule.sh <scenario> <distro> [molecule command, default: test]
# Distributions: debian13, ubuntu2404, ubuntu2604.
set -euo pipefail
# shellcheck source=scripts/lib.sh
source "$(dirname "$0")/lib.sh"

scenario="${1:?usage: $0 <scenario> <distro> [command]}"
distro="${2:?usage: $0 <scenario> <distro> [command]}"
command="${3:-test}"

case "$distro" in
  debian13) image="debian:13" ;;
  ubuntu2404) image="ubuntu:24.04" ;;
  ubuntu2604) image="ubuntu:26.04" ;;
  *) fail "unknown distro '$distro' (debian13, ubuntu2404, ubuntu2604)" ;;
esac

export MOLECULE_DISTRO="$distro" MOLECULE_IMAGE="$image"
log "molecule $command: scenario $scenario on $image"
cd "$REPO_ROOT"
exec molecule "$command" --scenario-name "$scenario"
