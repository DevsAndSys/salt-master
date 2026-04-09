# salt-master Helm chart

Minimal StatefulSet-based chart for Salt master.

## Quick install

```bash
helm upgrade --install salt-master oci://ghcr.io/devsandsys/charts/salt-master \
  --version <chart-version> \
  --set image.repository=ghcr.io/devsandsys/salt-master \
  --set image.tag=vX.Y.Z
```

`image.tag` should point to the GitHub Release tag `vX.Y.Z`.
The chart default is `latest`; if `image.tag` is set to an empty value, the template falls back to `.Chart.AppVersion`.

The chart package is published when a GitHub Release is published for this repo.
If pulls fail with auth errors, confirm the GHCR chart package visibility is `Public`.

## Public-safe Example Values

Start from:

- `values.example.public.yaml`

This file mirrors a production-style setup with external config, secret refs, GPG
key prep, and a readiness probe. All identities and sensitive data remain placeholders.

## Public-safe extension points

Use chart values to reference existing Kubernetes Secrets and ConfigMaps without
embedding secret material in Git:

- `imagePullSecrets`: image pull secret references.
- `extraEnv`: container env entries including `valueFrom`.
- `envFrom`: `secretRef`/`configMapRef` entries.
- `extraInitContainers`: raw init containers for runtime preparation steps.
- `readinessProbe`: optional exec-based readiness checks.
- `extraVolumes`: raw volumes such as secret or PVC volumes.
- `extraVolumeMounts`: raw mounts paired with `extraVolumes`.

Example:

```yaml
imagePullSecrets:
  - name: ghcr-pull

extraEnv:
  - name: DNS_API_URL
    valueFrom:
      secretKeyRef:
        name: salt-master-dns-api
        key: DNS_API_URL

extraVolumes:
  - name: gitfs-ssh
    secret:
      secretName: salt-master-gitfs-ssh

extraVolumeMounts:
  - name: gitfs-ssh
    mountPath: /var/lib/salt/.ssh
    readOnly: true
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
