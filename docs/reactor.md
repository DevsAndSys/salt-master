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

## PR highstate guard (optional pattern)

Use a guard reactor to inspect new job events and allow/block PR-related
highstate behavior based on your policy.

Example mapping:

```yaml
reactor:
  - 'salt/job/*/new':
    - salt://reactor/pr_highstate_guard.sls
```

Recommended behavior:

- Exit early for non-PR jobs.
- Perform only policy checks and lightweight routing decisions.
- Delegate long-running work to orchestrate runners/jobs.
