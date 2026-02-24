# salt-master Helm chart

Minimal StatefulSet-based chart for Salt master.

## Quick install

```bash
helm upgrade --install salt-master ./helm/salt-master \
  --set image.repository=<your-registry>/salt-master \
  --set image.tag=<tag>
```

## Chart docs

- `../../docs/SUMMARY.md`
- `../../docs/service-exposure.md`
- `../../docs/identity.md`
- `../../docs/config-management.md`
- `../../docs/gitfs.md`
- `../../docs/git-pillar.md`
- `../../docs/gpg-pillars.md`
- `../../docs/reactor.md`
- `../../docs/orchestrator.md`
