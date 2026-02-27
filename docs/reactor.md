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

Example `reactor/pr_highstate_guard.sls`:

```jinja
{# Guard only reacts to new state.apply jobs. #}
{% set fun = data.get('fun', '') %}
{% set meta = data.get('metadata', {}) %}
{% set is_state_apply = fun == 'state.apply' %}
{% set is_pr_change = meta.get('pr_change', False) %}
{% set approved = meta.get('approved', False) %}

{% if is_state_apply %}
{% if is_pr_change and approved %}
pr_highstate_guard_allow:
  runner.event.send:
    - tag: salt/reactor/pr_highstate_guard/allowed
    - data:
        jid: "{{ data.get('jid', '') }}"
        tgt: "{{ data.get('tgt', '') }}"
        user: "{{ data.get('user', '') }}"
{% else %}
pr_highstate_guard_deny:
  runner.event.send:
    - tag: salt/reactor/pr_highstate_guard/denied
    - data:
        jid: "{{ data.get('jid', '') }}"
        tgt: "{{ data.get('tgt', '') }}"
        user: "{{ data.get('user', '') }}"
        reason: "missing required metadata: pr_change=true and approved=true"
{% endif %}
{% endif %}
```

What this does:

- Watches `salt/job/*/new` events.
- Evaluates only `state.apply` jobs.
- Emits explicit `allowed`/`denied` events your automation can route on.

Recommended behavior in production:

- Exit early for non-PR jobs.
- Perform only policy checks and lightweight routing decisions.
- Delegate long-running work to orchestrate runners/jobs.
