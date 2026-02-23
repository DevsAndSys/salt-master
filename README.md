# Salt Master Container

This is an independent, community-maintained container image for running a
Salt-compatible master service. It is not affiliated with or endorsed by
Broadcom, VMware, or the Salt project trademark owners.

This image runs `salt-master` as a non-root user (UID 10001) with a read-only
root filesystem. Mount the writable paths listed below.

## Environment variables

Core:
- `SALT_MASTER_USER` (default `salt`)
- `SALT_MASTER_INTERFACE` (default `0.0.0.0`)
- `SALT_MASTER_PUBLISH_PORT` (default `4505`)
- `SALT_MASTER_RETURN_PORT` (default `4506`)
- `SALT_MASTER_WORKER_THREADS` (default `5`)
- `SALT_MASTER_LOG_LEVEL` (default `info`)
- `SALT_MASTER_LOG_FILE` (optional)
- `SALT_MASTER_LOG_LEVEL_LOGFILE` (optional)
- `SALT_MASTER_MAX_OPEN_FILES` (default `64000`)
- `SALT_MASTER_HASH_TYPE` (optional)
- `SALT_MASTER_OPEN_MODE` (optional)

Storage/paths:
- `SALT_MASTER_CONFIG_DIR` (default `/var/lib/salt/config`)
- `SALT_MASTER_PKI_DIR` (default `/var/lib/salt/pki`)
- `SALT_MASTER_RUN_DIR` (default `/var/lib/salt/run`)

Data roots:
- `SALT_MASTER_FILE_ROOTS` (comma-separated paths for `file_roots: base`)
- `SALT_MASTER_PILLAR_ROOTS` (comma-separated paths for `pillar_roots: base`)
- `SALT_MASTER_FILESERVER_BACKEND` (comma-separated list)
- `SALT_MASTER_FILE_IGNORE_GLOB` (comma-separated list)
- `SALT_MASTER_FILE_IGNORE_REGEX` (comma-separated list)

GitFS:
- `SALT_MASTER_GITFS_PROVIDER`
- `SALT_MASTER_GITFS_BASE`
- `SALT_MASTER_GITFS_ROOT`
- `SALT_MASTER_GITFS_REMOTES` (comma-separated list)
- `SALT_MASTER_GITFS_PRIVKEY`
- `SALT_MASTER_GITFS_PUBKEY`
- `SALT_MASTER_GITFS_PASSPHRASE`
- `SALT_MASTER_GITFS_SSL_VERIFY`
- `SALT_MASTER_GITFS_SALTENV_WHITELIST` (comma-separated list)
- `SALT_MASTER_GITFS_SALTENV_BLACKLIST` (comma-separated list)

Advanced:
- `SALT_MASTER_ID` (optional master id)
- `SALT_MASTER_AUTO_ACCEPT` (default `False`)
- `SALT_MASTER_EXTRA_CONFIG` (raw YAML appended to `master`)
- `SALT_MASTER_USE_EXISTING_CONFIG` (default `false`)

## Example run

```bash
docker run -d --name salt-master \
  --read-only \
  -e SALT_MASTER_MAX_OPEN_FILES=64000 \
  -v /path/pki:/var/lib/salt/pki \
  -v /path/config:/var/lib/salt/config \
  -v /path/log:/var/log/salt \
  -v /path/cache:/var/cache/salt \
  -v /path/run:/var/lib/salt/run \
  -p 4505:4505 -p 4506:4506 \
  salt-master-local
```

For Helm/Kubernetes deployments, define persistence and writable mounts in the
chart values and pod spec (PVC/`emptyDir`), rather than relying on Dockerfile
`VOLUME` declarations.

## Salt Cloud

```bash
docker run --rm --entrypoint salt-cloud salt-master-local --version
```
