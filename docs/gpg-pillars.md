# GPG-Encrypted Pillars Walkthrough

Use this flow to keep sensitive pillar values encrypted at rest in Git and only
decrypted by the Salt master at render time.

## 1) Generate a dedicated pillar keypair

Run on a secure workstation:

```bash
gpg --batch --quick-gen-key "salt-pillar@example.org" rsa4096 encrypt
gpg --armor --export-secret-keys "salt-pillar@example.org" > pillar-private.asc
gpg --armor --export "salt-pillar@example.org" > pillar-public.asc
```

Keep `pillar-private.asc` private. You can share `pillar-public.asc` with
contributors who need to encrypt pillar values.

## 2) Create encrypted pillar content

Encrypt a value:

```bash
printf '%s' 'super-secret-token' | \
  gpg --armor --trust-model always --encrypt -r "salt-pillar@example.org"
```

Example `pillar/secrets.sls` in your git_pillar repo:

```yaml
#!yaml|gpg
app:
  api_token: |
    -----BEGIN PGP MESSAGE-----
    ...
    -----END PGP MESSAGE-----
```

Reference in `pillar/top.sls`:

```yaml
base:
  '*':
    - app
    - secrets
```

## 3) Load private key into Kubernetes

Use a Secret and mount it read-only:

```bash
kubectl -n <salt-namespace> create secret generic salt-master-gpg \
  --from-file=private.asc=./pillar-private.asc
```

Then import into the keyring directory using an init container or custom image
startup logic. Minimal pattern in pod shell:

```bash
mkdir -p /var/lib/salt/gpgkeys
gpg --homedir /var/lib/salt/gpgkeys --import /etc/salt/gpg/private.asc
```

## 4) Configure Salt master for GPG rendering

Add to `SALT_MASTER_EXTRA_CONFIG`:

```yaml
env:
  SALT_MASTER_EXTRA_CONFIG: |
    gpg_keydir: /var/lib/salt/gpgkeys
    gpg_decrypt_must_succeed: True
```

Operational recommendation:

- Set `gpg_decrypt_must_succeed: True` so bad/missing keys fail fast.
- Restrict who can read pod logs and mounted secret material.
- Rotate keypairs on schedule and after any operator offboarding.

## 5) Verify decryption

From master pod:

```bash
salt-run pillar.show_pillar '<minion-id>' --out=yaml
```

Expected:

- Encrypted values are rendered in cleartext in pillar output for authorized
  minion scope.
- No `No secret key`/renderer errors in master logs.

If no minions are connected yet, at least validate key import:

```bash
gpg --homedir /var/lib/salt/gpgkeys --list-secret-keys
```

## 6) Failure modes

- `No secret key`: wrong keyring path, key not imported, or wrong recipient.
- `could not decrypt`: ciphertext corruption/newlines altered in YAML block.
- renderer failures on boot: invalid GPG homedir permissions.

## 7) Security baseline

- Keep private key out of Git and CI logs.
- Use namespace RBAC to restrict Secret read/list access.
- Prefer one keypair per environment (dev/stage/prod), not shared globally.
