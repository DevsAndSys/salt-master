# Reactor

## Purpose

Salt Reactor maps event-bus tags to reaction SLS files.

## Minimal configuration

Configure reactor mapping with `SALT_MASTER_EXTRA_CONFIG`:

```yaml
env:
  SALT_MASTER_EXTRA_CONFIG: |
    reactor:
      - 'salt/minion/*/start':
        - /var/lib/salt/config/states/reactor/minion-start.sls
```

## File placement

Ensure the referenced reactor SLS file is available in your file roots, for
example under `/var/lib/salt/config/states/reactor/` when using chart-managed
master config with read-only root filesystem.

## Operational guidance

- Keep reactor handlers idempotent.
- Avoid long/blocking handlers; trigger orchestration jobs instead.
- Restrict who can emit custom events if exposing event APIs.
