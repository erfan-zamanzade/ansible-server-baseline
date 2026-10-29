# Pinned tool versions and checksums. Sourced by lib.sh.
# shellcheck shell=bash

export UV_VERSION="0.12.24"
export UV_SHA256_x86_64="b4dfaef47d491a7296981f8374a4595f55dbf84e8937c8ecd2983574d8bb3da6"
export UV_SHA256_aarch64="5231be65f496304623895dacdbf1de8504fec90303684bdf05805aa34414dd21"

# Linters and test helpers that run as containers.
export SHELLCHECK_IMAGE="koalaman/shellcheck:v0.11.0"
export PROMETHEUS_IMAGE="prom/prometheus:v3.15.1"
export ACTIONLINT_IMAGE="rhysd/actionlint:1.7.12"
