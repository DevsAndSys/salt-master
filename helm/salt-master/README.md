# salt-master Helm chart

Minimal chart for deploying the container in this repository.

This chart always deploys Salt master as a `StatefulSet` to preserve stable
pod identity and avoid master PKI churn from hostname changes.

## Install

```bash
helm upgrade --install salt-master ./helm/salt-master \
  --set image.repository=<your-registry>/salt-master \
  --set image.tag=<tag>
```

## Exposure modes

- `NodePort` (default): exposes `30000-32767` ports on each node, forwarding to internal `4505/4506`.
- `ClusterIP`: internal-only service (override if needed).
- `LoadBalancer`: cloud/LB integration exposing internal `4505/4506`; optional source CIDR allowlist.

NodePort example (external `30000-32767` -> internal Salt ports):

```bash
helm upgrade --install salt-master ./helm/salt-master \
  --set service.type=NodePort \
  --set service.nodePort.enabled=true \
  --set service.nodePort.publish=31505 \
  --set service.nodePort.return=31506 \
  --set image.repository=<your-registry>/salt-master \
  --set image.tag=<tag>
```

LoadBalancer example (standard ports with source allowlist):

```bash
helm upgrade --install salt-master ./helm/salt-master \
  --set service.type=LoadBalancer \
  --set service.externalTrafficPolicy=Local \
  --set service.loadBalancer.sourceRanges[0]=203.0.113.10/32 \
  --set service.loadBalancer.sourceRanges[1]=198.51.100.0/24 \
  --set image.repository=<your-registry>/salt-master \
  --set image.tag=<tag>
```

The chart also creates a headless Service automatically and wires it to the
StatefulSet for stable network identity.

By default, `SALT_MASTER_ID` is set to FQDN form:
`<pod>.<headless-service>.<namespace>.svc.<clusterDomain>`.
Set `env.SALT_MASTER_ID` to override.

Cluster domain is configurable via:

```yaml
global:
  clusterDomain: cluster.local
```

## Required storage

- `/var/lib/salt/config`
- `/var/lib/salt/pki`

Runtime paths use `emptyDir` by default:

- `/var/lib/salt/run`
- `/var/cache/salt`
- `/var/log/salt`
