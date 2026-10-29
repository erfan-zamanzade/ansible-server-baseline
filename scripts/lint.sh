#!/usr/bin/env bash
# Static checks, no containers started for Ansible: yamllint, ansible-lint
# (production profile), syntax check, shellcheck, promtool and actionlint.
set -euo pipefail
# shellcheck source=scripts/lib.sh
source "$(dirname "$0")/lib.sh"
cd "$REPO_ROOT"

log "yamllint"
yamllint --strict .
ok "YAML is clean"

log "ansible-lint (production profile)"
ansible-lint --offline -q
ok "ansible-lint passed"

log "syntax check of the site playbook"
ansible-playbook --syntax-check -i inventories/example/hosts.yml playbooks/site.yml >/dev/null
ok "site.yml parses"

log "shellcheck"
docker run --rm -v "$REPO_ROOT:/mnt:ro" -w /mnt "$SHELLCHECK_IMAGE" -x \
  scripts/*.sh \
  roles/backup/files/backup-common.sh roles/backup/files/backup-run \
  roles/backup/files/backup-verify roles/backup/files/backup-restore-db \
  roles/healthcheck/files/server-healthcheck
ok "shell scripts are clean"

log "promtool: alert rules and their unit tests"
docker run --rm -v "$REPO_ROOT/monitoring:/m:ro" -w /m --entrypoint promtool "$PROMETHEUS_IMAGE" check rules alerts.yml >/dev/null
docker run --rm -v "$REPO_ROOT/monitoring:/m:ro" -w /m/tests --entrypoint promtool "$PROMETHEUS_IMAGE" test rules alerts.test.yml
ok "alert rules pass their tests"

log "actionlint"
docker run --rm -v "$REPO_ROOT:/repo:ro" -w /repo "$ACTIONLINT_IMAGE" -color
ok "workflows are clean"
