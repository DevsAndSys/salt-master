# GitFS

## Current image support

The published image supports GitFS out of the box with the `gitpython`
provider. It already includes:

- `git`
- `GitPython`

It does not include `pygit2`. Build a derivative image only if you specifically
need that provider.

## Configure master for GitFS

Set Salt master config via `SALT_MASTER_EXTRA_CONFIG` in chart values.

Example `values.yaml` snippet:

```yaml
env:
  SALT_MASTER_EXTRA_CONFIG: |
    fileserver_backend:
      - roots
      - git
    gitfs_provider: gitpython
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
