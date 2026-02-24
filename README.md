# salt-master

Repository layout:

- Container: `Dockerfile`, `entrypoint.sh`, `requirements.txt`
- Helm chart: `helm/salt-master`
- Docs: `docs/`

## Quick start

```bash
docker build -t salt-master:local .
helm upgrade --install salt-master ./helm/salt-master \
  --set image.repository=salt-master \
  --set image.tag=local
```

## Feature matrix

### Included binaries

| Component | Binary/command | Included | Primary use case |
|---|---|---|---|
| Salt master daemon | `salt-master` | Yes | Run the Salt control plane and event bus |
| Salt minion daemon | `salt-minion` | Yes | Optional co-located minion/loopback testing |
| Salt command client | `salt` | Yes | Remote execution against minions |
| Salt remote runner | `salt-run` | Yes | Runners, orchestration entry points, job management |
| Salt call local exec | `salt-call` | Yes | Local module/state execution and troubleshooting |
| Salt key manager | `salt-key` | Yes | Minion key acceptance/rejection lifecycle |
| Salt copy utility | `salt-cp` | Yes | Push files directly to minions |
| Salt API daemon | `salt-api` | Yes | REST integration via `rest_cherrypy` |
| Salt cloud tool | `salt-cloud` | Yes | Cloud VM lifecycle through libcloud providers |
| Salt SSH tool | `salt-ssh` | Yes | Agentless Salt operations over SSH |
| Salt proxy daemon | `salt-proxy` | Yes | Non-minion endpoint management via proxy minions |
| Salt syndic daemon | `salt-syndic` | Yes | Hierarchical multi-master topologies |
| Salt package manager | `spm` | Yes | Salt formula package management |
| Git client | `git` | Yes | `gitfs` and `git_pillar` backends |
| GPG tooling | `gpg` | Yes | Pillar encryption/decryption workflows |
| SSH client utilities | `ssh`, `sshpass` | Yes | `salt-ssh` connectivity and bootstrap flows |
| Network diagnostics | `curl`, `ip`, `ping`, `nc` | Yes | Connectivity and service troubleshooting from pod |

### Exposed ports

| Port | Protocol | Service | Related use case |
|---|---|---|---|
| `4505` | TCP | Salt publish bus | Master-to-minion command publish channel |
| `4506` | TCP | Salt return bus | Minion-to-master return/event channel |
| `8000` | TCP | `salt-api` (common default) | API/webhook integrations and external automation |

## Documentation

- `docs/SUMMARY.md`
- `docs/quickstart.md`
- `docs/gitfs.md`
- `docs/reactor.md`
- `docs/orchestrator.md`
