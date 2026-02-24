# Identity

The chart always deploys Salt master as a `StatefulSet` with a headless
Service, so pod identity is stable.

Default identity pattern:

`<pod>.<headless-service>.<namespace>.svc.<clusterDomain>`

## How default ID is computed

If `env.SALT_MASTER_ID` is not provided, `entrypoint.sh` computes it at runtime
from downward-API env vars:

- `POD_NAME`
- `POD_NAMESPACE`
- `SALT_MASTER_HEADLESS_SERVICE`
- `SALT_MASTER_CLUSTER_DOMAIN`

This avoids Kubernetes non-expansion of `$(VAR)` inside static env values.

## Configure cluster domain

```yaml
global:
  clusterDomain: cluster.local
```

## Explicit override

```yaml
env:
  SALT_MASTER_ID: salt-master-0.salt-master-headless.salt.svc.cluster.local
```
