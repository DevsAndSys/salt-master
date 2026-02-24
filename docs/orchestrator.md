# Orchestrator

## Purpose

Salt Orchestrate (`state.orch`) coordinates multi-minion workflows from the
master.

## Minimal master config

Most setups only need orchestrate SLS files in file roots. Optionally add
runner tuning via `SALT_MASTER_EXTRA_CONFIG`.

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
- With this chart's default hardened filesystem, place states under a writable
  configured file root (for example `/var/lib/salt/config/states`), not
  `/srv/salt`.
- Keep orchestration logic declarative and idempotent.
- Use requisites and explicit ordering; avoid hidden side effects.
