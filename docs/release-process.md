# Release Process

## Problem

This repo publishes two public-consumption artifacts:

- container image: `ghcr.io/devsandsys/salt-master`
- OCI Helm chart: `oci://ghcr.io/devsandsys/charts/salt-master`

Publishing them automatically from every push to `main` makes package state hard to
reason about and mixes CI with release intent.

## Decision

Publication is release-driven:

- publishing a GitHub Release triggers both GHCR workflows
- manual workflow dispatch remains available for exceptional recovery cases
- public access still depends on each GHCR package being set to `Public`

## Invariants

- no workflow creates git tags automatically
- release tags for the image use `vX.Y.Z` format
- chart publication packages the checked-in chart version from `helm/salt-master/Chart.yaml`
- consumers pin both the chart version and image tag

## Verification

- publish workflows should only trigger on `release.published` or manual dispatch
- `helm lint ./helm/salt-master` must pass before chart publication
- after publication, verify anonymous access to both packages

## Operator checklist

- [ ] merge the intended release commit to `main`
- [ ] ensure `helm/salt-master/Chart.yaml` has the intended chart version
- [ ] create and publish GitHub Release `vX.Y.Z`
- [ ] confirm the GHCR image package is `Public`
- [ ] confirm the GHCR chart package is `Public`
- [ ] test `docker pull ghcr.io/devsandsys/salt-master:vX.Y.Z`
- [ ] test `helm pull oci://ghcr.io/devsandsys/charts/salt-master --version <chart-version>`
