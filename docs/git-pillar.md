# Git Pillar

## Current image constraint

This repository ships a minimal image. Git-backed pillar requires Git tooling in
runtime (`git` binary + `GitPython`/`pygit2` stack).

If you need `git_pillar`, use a derivative image that includes those
dependencies.

## Configure git_pillar

Set pillar backend in `SALT_MASTER_EXTRA_CONFIG`.

Example `values.yaml` snippet:

```yaml
env:
  SALT_MASTER_EXTRA_CONFIG: |
    ext_pillar:
      - git:
        - main ssh://git@github.com/example/salt-pillar.git
```

Multiple environments/remotes example:

```yaml
env:
  SALT_MASTER_EXTRA_CONFIG: |
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
    git_pillar_provider: pygit2
    git_pillar_privkey: /etc/salt/git/id_rsa
    git_pillar_pubkey: /etc/salt/git/id_rsa.pub
```

Keep pillar repos private and read-only from the master.
