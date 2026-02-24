# Quickstart (TL;DR)

This is the fast path to deploy Salt master and start managing minions.

## 1) Verify chart access

```bash
helm show chart oci://ghcr.io/devsandsys/charts/salt-master --version 0.1.0
```

If this command returns auth errors, confirm `salt-master` and chart packages are public in GHCR.

## 2) Deploy Salt master

```bash
helm upgrade --install salt-master oci://ghcr.io/devsandsys/charts/salt-master \
  --version 0.1.0 \
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

## Last validated

- Timestamp (UTC): `2026-02-24T00:35:25Z`
- Kubernetes: `v1.34.0`
- Salt release: `salt-master` revision `12` in namespace `salt`
- Verified flow: GHCR chart deploy, key acceptance, `test.ping`, `state.highstate`, and `state.orchestrate`

Validation notes from this run:

- `orch/deploy.sls` was seeded as part of step 3 so the optional orchestrate step can run successfully.
