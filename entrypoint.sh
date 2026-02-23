#!/bin/sh
set -eu

CONFIG_DIR="${SALT_MASTER_CONFIG_DIR:-/var/lib/salt/config}"
CONFIG_PATH="${CONFIG_DIR%/}/master"
PKI_BASE_DIR="${SALT_MASTER_PKI_DIR:-/var/lib/salt/pki}"
PKI_MASTER_DIR="${PKI_BASE_DIR%/}/master"
RUN_DIR="${SALT_MASTER_RUN_DIR:-/var/lib/salt/run}"
GPG_KEYDIR="${SALT_MASTER_GPG_KEYDIR:-}"
GPG_IMPORT_KEY="${SALT_MASTER_GPG_IMPORT_KEY:-}"

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

write_scalar_config() {
  key="$1"
  value="$2"
  if [ -n "$value" ]; then
    printf "%s: %s\n" "$key" "$value" >> "$CONFIG_PATH"
  fi
}

if [ -n "$GPG_KEYDIR" ]; then
  mkdir -p "$GPG_KEYDIR"
  chmod 0700 "$GPG_KEYDIR" || true
fi

mkdir -p "$CONFIG_DIR" "$PKI_MASTER_DIR" "$RUN_DIR/master"

if [ ! -w "$CONFIG_DIR" ] || [ ! -w "$PKI_BASE_DIR" ] || [ ! -w "$RUN_DIR" ]; then
  echo "Error: write access required to $CONFIG_DIR, $PKI_BASE_DIR, and $RUN_DIR" >&2
  echo "Fix volume permissions/ownership for the non-root salt user." >&2
  exit 1
fi

if [ -n "$GPG_KEYDIR" ] && [ ! -w "$GPG_KEYDIR" ]; then
  echo "Error: write access required to $GPG_KEYDIR for GPG keydir" >&2
  exit 1
fi

USE_EXISTING_CONFIG="${SALT_MASTER_USE_EXISTING_CONFIG:-false}"

if [ "$USE_EXISTING_CONFIG" != "true" ] || [ ! -f "$CONFIG_PATH" ]; then
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

  # GitFS configuration
  append_list_config "fileserver_backend" "${SALT_MASTER_FILESERVER_BACKEND:-}"
  append_list_config "gitfs_remotes" "${SALT_MASTER_GITFS_REMOTES:-}"
  write_scalar_config "gitfs_provider" "${SALT_MASTER_GITFS_PROVIDER:-}"
  write_scalar_config "gitfs_base" "${SALT_MASTER_GITFS_BASE:-}"
  write_scalar_config "gitfs_root" "${SALT_MASTER_GITFS_ROOT:-}"
  write_scalar_config "gitfs_privkey" "${SALT_MASTER_GITFS_PRIVKEY:-}"
  write_scalar_config "gitfs_pubkey" "${SALT_MASTER_GITFS_PUBKEY:-}"
  write_scalar_config "gitfs_passphrase" "${SALT_MASTER_GITFS_PASSPHRASE:-}"
  write_scalar_config "gitfs_ssl_verify" "${SALT_MASTER_GITFS_SSL_VERIFY:-}"
  append_list_config "gitfs_saltenv_whitelist" "${SALT_MASTER_GITFS_SALTENV_WHITELIST:-}"
  append_list_config "gitfs_saltenv_blacklist" "${SALT_MASTER_GITFS_SALTENV_BLACKLIST:-}"

  if [ -n "${SALT_MASTER_GPG_KEYDIR:-}" ]; then
    printf "gpg_keydir: %s\n" "$SALT_MASTER_GPG_KEYDIR" >> "$CONFIG_PATH"
  fi

  if [ -n "${SALT_MASTER_GPG_DECRYPT_MUST_SUCCEED:-}" ]; then
    printf "gpg_decrypt_must_succeed: %s\n" "$SALT_MASTER_GPG_DECRYPT_MUST_SUCCEED" >> "$CONFIG_PATH"
  fi
fi

if [ -n "$GPG_KEYDIR" ] && [ -n "$GPG_IMPORT_KEY" ] && [ -f "$GPG_IMPORT_KEY" ]; then
  if ! gpg --homedir "$GPG_KEYDIR" --list-secret-keys --with-colons 2>/dev/null | grep -q '^sec:'; then
    gpg --homedir "$GPG_KEYDIR" --batch --import "$GPG_IMPORT_KEY" >/dev/null
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
