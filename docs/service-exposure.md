# Service Exposure

## Security warning

`4505/tcp` and `4506/tcp` must never be exposed broadly. Restrict inbound
traffic to known minion CIDRs using cloud firewalls/security groups and
Kubernetes policy controls.

## Modes

- Default: `NodePort` (`31505`/`31506` -> internal `4505`/`4506`)
- Alternatives: `ClusterIP`, `LoadBalancer`

## NodePort constraints

- Chart validates NodePort values in Kubernetes range `30000-32767`.
- NodePort collisions will fail install/upgrade (`port is already allocated`).
- Use per-environment NodePort overrides to avoid collisions.

### NodePort example

```bash
helm upgrade --install salt-master ./helm/salt-master \
  --set service.type=NodePort \
  --set service.nodePort.enabled=true \
  --set service.nodePort.publish=31505 \
  --set service.nodePort.return=31506
```

### LoadBalancer example

```bash
helm upgrade --install salt-master ./helm/salt-master \
  --set service.type=LoadBalancer \
  --set service.externalTrafficPolicy=Local \
  --set service.loadBalancer.sourceRanges[0]=203.0.113.10/32
```

## Readiness note

`4505` may accept connections slightly before `4506` during startup.
Treat both ports as ready only after Salt master logs show request server bound
on `tcp://0.0.0.0:4506`.
