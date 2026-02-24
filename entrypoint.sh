#!/bin/sh
set -eu

CONFIG_DIR="${SALT_MASTER_CONFIG_DIR:-/var/lib/salt/config}"
CONFIG_PATH="${CONFIG_DIR%/}/master"
PKI_BASE_DIR="${SALT_MASTER_PKI_DIR:-/var/lib/salt/pki}"
PKI_MASTER_DIR="${PKI_BASE_DIR%/}/master"
RUN_DIR="${SALT_MASTER_RUN_DIR:-/var/lib/salt/run}"
USE_EXISTING_CONFIG="${SALT_MASTER_USE_EXISTING_CONFIG:-false}"
POD_NAME="${POD_NAME:-}"
POD_NAMESPACE="${POD_NAMESPACE:-}"
SALT_MASTER_HEADLESS_SERVICE="${SALT_MASTER_HEADLESS_SERVICE:-}"
SALT_MASTER_CLUSTER_DOMAIN="${SALT_MASTER_CLUSTER_DOMAIN:-cluster.local}"

if [ -z "${SALT_MASTER_ID:-}" ] && [ -n "$POD_NAME" ] && [ -n "$POD_NAMESPACE" ] && [ -n "$SALT_MASTER_HEADLESS_SERVICE" ]; then
  SALT_MASTER_ID="${POD_NAME}.${SALT_MASTER_HEADLESS_SERVICE}.${POD_NAMESPACE}.svc.${SALT_MASTER_CLUSTER_DOMAIN}"
fi

append_list_config() {
  key="$1"
  values="$2"

  if [ -n "$values" ]; then
    printf "%s:\n" "$key" >> "$CONFIG_PATH"
    OLD_IFS=$IFS
    IFS=','
    for value in $values; do
      if [ -n "$value" ]; then
        printf "  - %s\n" "$value" >> "$CONFIG_PATH"
      fi
    done
    IFS=$OLD_IFS
  fi
}

mkdir -p "$CONFIG_DIR" "$PKI_MASTER_DIR" "$RUN_DIR/master"

if [ ! -w "$PKI_BASE_DIR" ] || [ ! -w "$RUN_DIR" ]; then
  echo "Error: write access required to $PKI_BASE_DIR and $RUN_DIR" >&2
  echo "Fix volume permissions/ownership for the non-root salt user." >&2
  exit 1
fi

if [ "$USE_EXISTING_CONFIG" = "true" ]; then
  if [ ! -r "$CONFIG_PATH" ]; then
    echo "Error: SALT_MASTER_USE_EXISTING_CONFIG=true but $CONFIG_PATH is missing or unreadable" >&2
    exit 1
  fi
else
  if [ ! -w "$CONFIG_DIR" ]; then
    echo "Error: write access required to $CONFIG_DIR when generating master config" >&2
    exit 1
  fi
fi

if [ "$USE_EXISTING_CONFIG" != "true" ]; then
  LOG_LEVEL="${SALT_MASTER_LOG_LEVEL:-info}"
  LOG_FILE="${SALT_MASTER_LOG_FILE:-/dev/stdout}"

  cat > "$CONFIG_PATH" <<EOF
user: ${SALT_MASTER_USER:-salt}
interface: ${SALT_MASTER_INTERFACE:-0.0.0.0}
publish_port: ${SALT_MASTER_PUBLISH_PORT:-4505}
ret_port: ${SALT_MASTER_RETURN_PORT:-4506}
worker_threads: ${SALT_MASTER_WORKER_THREADS:-5}
log_level: ${LOG_LEVEL}
log_file: ${LOG_FILE}
log_level_logfile: ${LOG_LEVEL}
auto_accept: ${SALT_MASTER_AUTO_ACCEPT:-False}
pki_dir: ${PKI_BASE_DIR}
sock_dir: ${RUN_DIR}/master
pidfile: ${RUN_DIR}/salt-master.pid
max_open_files: ${SALT_MASTER_MAX_OPEN_FILES:-64000}
EOF

  if [ -n "${SALT_MASTER_ID:-}" ]; then
    printf "id: %s\n" "$SALT_MASTER_ID" >> "$CONFIG_PATH"
  fi

  if [ -n "${SALT_MASTER_LOG_LEVEL_LOGFILE:-}" ]; then
    printf "log_level_logfile: %s\n" "$SALT_MASTER_LOG_LEVEL_LOGFILE" >> "$CONFIG_PATH"
  fi

  if [ -n "${SALT_MASTER_HASH_TYPE:-}" ]; then
    printf "hash_type: %s\n" "$SALT_MASTER_HASH_TYPE" >> "$CONFIG_PATH"
  fi

  if [ -n "${SALT_MASTER_OPEN_MODE:-}" ]; then
    printf "open_mode: %s\n" "$SALT_MASTER_OPEN_MODE" >> "$CONFIG_PATH"
  fi

  if [ -n "${SALT_MASTER_FILE_ROOTS:-}" ]; then
    printf "file_roots:\n  base:\n" >> "$CONFIG_PATH"
    OLD_IFS=$IFS
    IFS=','
    for path in $SALT_MASTER_FILE_ROOTS; do
      if [ -n "$path" ]; then
        printf "    - %s\n" "$path" >> "$CONFIG_PATH"
      fi
    done
    IFS=$OLD_IFS
  fi

  if [ -n "${SALT_MASTER_PILLAR_ROOTS:-}" ]; then
    printf "pillar_roots:\n  base:\n" >> "$CONFIG_PATH"
    OLD_IFS=$IFS
    IFS=','
    for path in $SALT_MASTER_PILLAR_ROOTS; do
      if [ -n "$path" ]; then
        printf "    - %s\n" "$path" >> "$CONFIG_PATH"
      fi
    done
    IFS=$OLD_IFS
  fi

  append_list_config "file_ignore_glob" "${SALT_MASTER_FILE_IGNORE_GLOB:-}"
  append_list_config "file_ignore_regex" "${SALT_MASTER_FILE_IGNORE_REGEX:-}"

  if [ -n "${SALT_MASTER_EXTRA_CONFIG:-}" ]; then
    printf "\n%s\n" "$SALT_MASTER_EXTRA_CONFIG" >> "$CONFIG_PATH"
  fi

fi

MASTER_PEM="${PKI_MASTER_DIR}/master.pem"
MASTER_PUB="${PKI_MASTER_DIR}/master.pub"

if [ ! -f "$MASTER_PEM" ] || [ ! -f "$MASTER_PUB" ]; then
  salt-key --gen-keys=master --gen-keys-dir "$PKI_MASTER_DIR" >/dev/null
fi

chmod 0600 "$MASTER_PEM"
chmod 0644 "$MASTER_PUB"

LOG_LEVEL="${SALT_MASTER_LOG_LEVEL:-}"
if [ -n "$LOG_LEVEL" ]; then
  exec salt-master -c "$CONFIG_DIR" -l "$LOG_LEVEL"
fi

exec salt-master -c "$CONFIG_DIR"
