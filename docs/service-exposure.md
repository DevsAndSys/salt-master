# Service Exposure

## Security warning

`4505/tcp` and `4506/tcp` must never be exposed broadly. Restrict inbound
traffic to known minion CIDRs with cloud firewalls, security groups, and
Kubernetes policy controls.

## Modes

- Default: `NodePort`, mapping `31505` and `31506` to internal `4505` and `4506`
- Alternatives: `ClusterIP`, `LoadBalancer`

## NodePort constraints

- The chart validates NodePort values in the Kubernetes range `30000-32767`.
- NodePort collisions will fail install or upgrade with `port is already allocated`.
- Use per-environment NodePort overrides to avoid collisions.

### NodePort example

```bash
helm upgrade --install salt-master oci://ghcr.io/devsandsys/charts/salt-master \
  --version <chart-version> \
  --set image.repository=ghcr.io/devsandsys/salt-master \
  --set image.tag=vX.Y.Z \
  --set service.type=NodePort \
  --set service.nodePort.enabled=true \
  --set service.nodePort.publish=31505 \
  --set service.nodePort.return=31506
```

### LoadBalancer example

```bash
helm upgrade --install salt-master oci://ghcr.io/devsandsys/charts/salt-master \
  --version <chart-version> \
  --set image.repository=ghcr.io/devsandsys/salt-master \
  --set image.tag=vX.Y.Z \
  --set service.type=LoadBalancer \
  --set service.externalTrafficPolicy=Local \
  --set service.loadBalancer.sourceRanges[0]=203.0.113.10/32
```

## Readiness note

`4505` may accept connections slightly before `4506` during startup.
Treat both ports as ready only after the Salt master logs show the request server
bound on `tcp://0.0.0.0:4506`.
