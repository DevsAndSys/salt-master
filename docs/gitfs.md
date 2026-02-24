# GitFS

## Current image constraint

This repository ships a minimal image. It does **not** include GitFS-specific
runtime dependencies (`pygit2`/`GitPython`) or `git` binary packages.

If you need GitFS, build a derivative image that adds:

- `git` OS package
- `pygit2` and/or `GitPython` Python packages

## Configure master for GitFS

Set Salt master config via `SALT_MASTER_EXTRA_CONFIG` in chart values.

Example `values.yaml` snippet:

```yaml
env:
  SALT_MASTER_EXTRA_CONFIG: |
    fileserver_backend:
      - roots
      - git
    gitfs_provider: pygit2
    gitfs_remotes:
      - ssh://git@github.com/example/salt-states.git
    gitfs_base: main
```

## SSH key material

Provide deploy keys to the pod (Secret + volumeMount), then reference paths in
`SALT_MASTER_EXTRA_CONFIG`:

```yaml
env:
  SALT_MASTER_EXTRA_CONFIG: |
    gitfs_privkey: /etc/salt/gitfs/id_rsa
    gitfs_pubkey: /etc/salt/gitfs/id_rsa.pub
```

Keep known_hosts pinned and scope key access to read-only repositories.
