# salt-master docs

Start here:

- `SUMMARY.md`: documentation table of contents.

Core operations:

- `quickstart.md`: fast deploy/provision flow for Salt operators.
- `release-process.md`: release-driven GHCR publication and public package checks.
- `service-exposure.md`: NodePort/ClusterIP/LoadBalancer exposure and security.
- `identity.md`: StatefulSet identity model and `SALT_MASTER_ID` defaults.
- `config-management.md`: generated vs external config modes and rollout model.

Advanced Salt workflows:

- `gitfs.md`: enable GitFS with this chart and the image's supported Git backends.
- `git-pillar.md`: configure `git_pillar` with SSH-backed pillar repos.
- `gpg-pillars.md`: encrypt/decrypt sensitive pillar values with GPG.
- `reactor.md`: configure Salt Reactor on this deployment.
- `orchestrator.md`: configure and run orchestration states.
