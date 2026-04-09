# Quickstart (TL;DR)

This is the fast path to deploy Salt master and start managing minions.

## 1) Verify chart access

```bash
helm show chart oci://ghcr.io/devsandsys/charts/salt-master --version <chart-version>
```

If this command returns auth errors, confirm the image and chart packages are public in GHCR.

Published packages are release-driven. If a package was deleted or made private,
re-publish it from a GitHub Release and restore package visibility to `Public`.

## 2) Deploy Salt master

```bash
helm upgrade --install salt-master oci://ghcr.io/devsandsys/charts/salt-master \
  --version <chart-version> \
  -n salt --create-namespace \
  --set image.repository=ghcr.io/devsandsys/salt-master \
  --set image.tag=vX.Y.Z \
  --set-string env.SALT_MASTER_FILE_ROOTS=/var/lib/salt/config/states \
  --set env.SALT_MASTER_AUTO_ACCEPT=False

kubectl -n salt rollout status sts/salt-master-salt-master --timeout=240s
```

## 3) Seed baseline states on master

```bash
kubectl -n salt exec salt-master-salt-master-0 -- sh -lc '
mkdir -p /var/lib/salt/config/states/base
cat > /var/lib/salt/config/states/top.sls <<"SLS"
base:
  "*":
    - base.ping
SLS
cat > /var/lib/salt/config/states/base/ping.sls <<"SLS"
ping_ok:
  test.succeed_without_changes
SLS
'
```

## 4) Configure minions (outside cluster)

On each minion host:

```bash
cat >/etc/salt/minion.d/master.conf <<'CONF'
master: <MASTER_IP_OR_DNS>
master_port: 4506
id: <MINION_ID>
CONF

systemctl restart salt-minion || service salt-minion restart || rc-service salt-minion restart
```

## 5) Approve and verify from master

```bash
kubectl -n salt exec salt-master-salt-master-0 -- sh -lc '
/opt/salt/bin/salt-key -c /var/lib/salt/config -L
/opt/salt/bin/salt-key -c /var/lib/salt/config -A -y
/opt/salt/bin/salt -c /var/lib/salt/config "*" test.ping --timeout=20
'
```

Right after key acceptance, the first `test.ping` may return no response while minions finish startup.
Run `test.ping` once more before continuing.

By default, the chart Service is `NodePort`, so `<MASTER_IP_OR_DNS>` must be reachable by minions on the published Salt ports.

## 6) Apply states

```bash
kubectl -n salt exec salt-master-salt-master-0 -- sh -lc '
/opt/salt/bin/salt -c /var/lib/salt/config "*" state.highstate --timeout=120 --static
'
```

## 7) Optional: run orchestrate

```bash
kubectl -n salt exec salt-master-salt-master-0 -- sh -lc '
/opt/salt/bin/salt-run -c /var/lib/salt/config state.orchestrate orch.deploy saltenv=base
'
```

## 8) Exposure reminder

Keep inbound access to `4505/tcp` and `4506/tcp` restricted to known minion CIDRs.
See `docs/service-exposure.md` for service mode details.

## Troubleshooting: non-root minion runtime paths

When running `salt-minion` from this image as non-root, default paths under `/etc/salt`
and `/var/run` can cause permission errors.

Do not place `pki_dir` on `/tmp`. If that directory is cleared, the minion loses
its cached keys and has to re-establish trust with the master.

Use persistent writable paths for PKI and cache. Reserve `/tmp` only for
short-lived runtime files if needed. For example:

```yaml
pki_dir: /var/lib/salt/pki/minion
cachedir: /var/cache/salt/minion
sock_dir: /var/run/salt/minion
log_file: /var/log/salt/minion
pidfile: /var/run/salt/minion.pid
```

If the first `test.ping` after key acceptance returns no response, try again after a short delay.
