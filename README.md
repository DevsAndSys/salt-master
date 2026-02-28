# salt-master

Published artifacts:

- Image: `ghcr.io/devsandsys/salt-master`
- Helm chart (OCI): `oci://ghcr.io/devsandsys/charts/salt-master`

## Quick start (GHCR)

```bash
# Install directly from published chart + published image
helm upgrade --install salt-master oci://ghcr.io/devsandsys/charts/salt-master \
  --version 0.1.0 \
  --set image.repository=ghcr.io/devsandsys/salt-master \
  --set image.tag=vX.Y.Z
```

If pull/install fails with auth errors, re-check package visibility in GHCR.

For deterministic deploys in GitOps, pin both:
- chart version (`--version`, for example `0.1.0`)
- image tag (`vX.Y.Z` semver produced by CI), not `latest`

Latest released image tags:

```bash
gh api repos/DevsAndSys/salt-master/tags --paginate | jq -r '.[].name' | sort -V | tail
```

## Release hygiene (maintainers)

If a bad release commit/tag is pushed by mistake, use this cleanup flow:

```bash
# 1) Revert bad commits in a dedicated fix branch (no history rewrite on main)
git checkout -b fix/revert-bad-release origin/main
git revert --no-edit <bad_commit_sha_1> [<bad_commit_sha_2> ...]
git push -u origin fix/revert-bad-release
# Open a PR and merge after checks pass

# 2) Delete accidental remote tags
git push origin :refs/tags/<bad_tag_1> :refs/tags/<bad_tag_2>

# 3) (Optional) Delete workflow runs tied to bad SHAs
gh run list --repo DevsAndSys/salt-master --limit 200 --json databaseId,headSha
gh api -X DELETE /repos/DevsAndSys/salt-master/actions/runs/<run_id>
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
