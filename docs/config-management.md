# Master Config Management

## Modes

### Generated (default)

Entrypoint generates `/var/lib/salt/config/master` from env values.

```yaml
config:
  mode: generated
```

### External

Mounts `master` from ConfigMap/projected volume as read-only.

```yaml
config:
  mode: external
  external:
    source: configMap
    configMap:
      create: false
      name: salt-master-master-config
      key: master
```

## External config requirements (validated)

When `config.mode=external`, your `master` file must include writable runtime
paths. If omitted, Salt defaults to `/etc/salt/*` and fails on read-only FS.

Minimum recommended keys:

```yaml
user: salt
interface: 0.0.0.0
publish_port: 4505
ret_port: 4506
worker_threads: 5
log_level: info
log_file: /dev/stdout
log_level_logfile: info
auto_accept: False
pki_dir: /var/lib/salt/pki
sock_dir: /var/lib/salt/run/master
pidfile: /var/lib/salt/run/salt-master.pid
max_open_files: 64000
```

## Chart-managed ConfigMap example

```yaml
config:
  mode: external
  external:
    source: configMap
    configMap:
      create: true
      key: master
      data: |
        user: salt
        interface: 0.0.0.0
        publish_port: 4505
        ret_port: 4506
        worker_threads: 5
        log_level: info
        log_file: /dev/stdout
        log_level_logfile: info
        auto_accept: False
        pki_dir: /var/lib/salt/pki
        sock_dir: /var/lib/salt/run/master
        pidfile: /var/lib/salt/run/salt-master.pid
        max_open_files: 64000
```

## Projected source example

```yaml
config:
  mode: external
  external:
    source: projected
    projected:
      defaultMode: 0444
      sources:
        - configMap:
            name: salt-master-projected-config
            items:
              - key: master
                path: master
```

## Validation guards implemented in chart

- `global.clusterDomain` must be non-empty.
- `config.mode` must be `generated` or `external`.
- If `external + configMap` and `create=false`, `configMap.name` is required.
- If `external + projected`, `projected.sources` must be non-empty.

## Reload behavior

- Chart-managed ConfigMap (`create=true`) triggers rollout via checksum annotation.
- For unmanaged external sources, use manual GitOps rollout token:

```yaml
config:
  rollout:
    restartToken: "2026-02-23T22:00:00Z"
```

Bump `restartToken` to any new value to force StatefulSet pod recreation.
