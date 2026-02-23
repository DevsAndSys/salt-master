# salt-master

Repository structure:

- `Dockerfile`, `entrypoint.sh`, `requirements.txt`: container build/runtime.
- `helm/salt-master`: minimal Helm chart for Kubernetes deployment.

## Quick start

Build image:

```bash
docker build -t salt-master:local .
```

Install chart:

```bash
helm upgrade --install salt-master ./helm/salt-master \
  --set image.repository=salt-master \
  --set image.tag=local
```
