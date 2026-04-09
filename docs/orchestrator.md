# Orchestrator

## Purpose

`state.orch` coordinates multi-minion workflows from the master.

## Minimal master config

Most setups only need orchestration SLS files in file roots. Add runner tuning
through `SALT_MASTER_EXTRA_CONFIG` only if needed.

Example:

```yaml
env:
  SALT_MASTER_EXTRA_CONFIG: |
    runner_returns: local_cache
```

## Typical run

From master pod:

```bash
/opt/salt/bin/salt-run -c /var/lib/salt/config state.orch orch.deploy_app saltenv=base
```

## Recommended layout

- `orch/` directory for orchestration SLS files.
- With the chart's default filesystem layout, place states under a writable file
  root such as `/var/lib/salt/config/states`, not `/srv/salt`.
- Keep orchestration logic declarative and idempotent.
- Use requisites and explicit ordering; avoid hidden side effects.
