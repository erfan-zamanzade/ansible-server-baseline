# Shared by backup-run, backup-verify and backup-restore-db. Source it.
# shellcheck shell=bash

# shellcheck source=/dev/null
source /etc/backup/backup.conf
set -a
# shellcheck source=/dev/null
source /etc/restic/env
set +a

log() { printf '%s %s\n' "$(date -u +%FT%TZ)" "$*" >&2; }
die() { log "ERROR: $*"; exit 1; }

# write_metrics NAME: read Prometheus text format on stdin and publish it
# atomically for node_exporter's textfile collector.
write_metrics() {
  local file="$BACKUP_TEXTFILE_DIR/$1.prom" tmp
  [[ -d "$BACKUP_TEXTFILE_DIR" ]] || { cat >/dev/null; return 0; }
  tmp="$(mktemp "$BACKUP_TEXTFILE_DIR/.$1.XXXXXX")"
  cat >"$tmp"
  chmod 0644 "$tmp"
  mv -f "$tmp" "$file"
}

# previous_metric NAME FILE: last published value of a metric, or 0.
previous_metric() {
  awk -v m="$1" '$1 == m { print $2; found = 1 } END { if (!found) print 0 }' \
    "$BACKUP_TEXTFILE_DIR/$2.prom" 2>/dev/null || echo 0
}

# split_pg_entry ENTRY: set PG_CONTAINER PG_DATABASE PG_USER PG_VERIFY_SQL PG_VERIFY_MIN.
# shellcheck disable=SC2034  # the variables are used by the calling scripts
split_pg_entry() {
  IFS='|' read -r PG_CONTAINER PG_DATABASE PG_USER PG_VERIFY_SQL PG_VERIFY_MIN <<<"$1"
}
