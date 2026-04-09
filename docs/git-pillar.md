# Git Pillar

## Current image support

The published image supports `git_pillar` out of the box with the `gitpython`
provider. It already includes:

- `git`
- `GitPython`

It does not include `pygit2`. Build a derivative image only if you specifically
need that provider.

## Configure git_pillar

Set pillar backend in `SALT_MASTER_EXTRA_CONFIG`.

Example `values.yaml` snippet:

```yaml
env:
  SALT_MASTER_EXTRA_CONFIG: |
    git_pillar_provider: gitpython
    ext_pillar:
      - git:
        - main ssh://git@github.com/example/salt-pillar.git
```

Multiple environments/remotes example:

```yaml
env:
  SALT_MASTER_EXTRA_CONFIG: |
    git_pillar_provider: gitpython
    ext_pillar:
      - git:
        - main ssh://git@github.com/example/salt-pillar.git
        - dev ssh://git@github.com/example/salt-pillar-dev.git
```

## SSH key material

Mount deploy keys and known_hosts from a Secret, then point config to key paths:

```yaml
env:
  SALT_MASTER_EXTRA_CONFIG: |
    git_pillar_provider: gitpython
    git_pillar_privkey: /etc/salt/git/id_rsa
    git_pillar_pubkey: /etc/salt/git/id_rsa.pub
```

Keep pillar repos private and read-only from the master.
