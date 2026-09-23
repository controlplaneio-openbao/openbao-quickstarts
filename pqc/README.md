# Show Case OpenBao 2.7 PQC Features

Required binaries:
* bao 2.7+
* openssl 3.5+
* jq

## Bootstrap the server

```sh
mkdir -p .runtime
# path from openbao.d/02-seal.hcl
openssl rand -out .runtime/seal.key 32
# DEMO_ADMIN_PASSWORD is used in openbao.d/05-init-admin.hcl
DEMO_ADMIN_PASSWORD=student bao server -config openbao.d
```

## PQC listener with external certificate

```sh
export BAO_ADDR=https://127.0.0.1:8200
export BAO_CACERT=$PWD/openbao.d/bootstrap-cert.pem
bao status
bao login -method=userpass username=admin password=student
```

## Verify the handshake

```sh
openssl s_client -connect 127.0.0.1:8200 -CAfile tls/ca.pem </dev/null \
  | grep -E 'Peer signature type|Negotiated TLS1.3 group|Verification'
# both of these must fail
openssl s_client -connect 127.0.0.1:8200 -CAfile tls/ca.pem -groups X25519 </dev/null
openssl s_client -connect 127.0.0.1:8200 -CAfile tls/ca.pem -tls1_2 </dev/null
```

## Issue PQC cert in OpenBao

```sh
bao secrets list
bao read -field=certificate pki/cert/ca > tls/ca.pem
openssl x509 -in tls/ca.pem -noout -subject -text | grep -E 'subject=|Public Key Algorithm'
bao write -format=json pki/issue/openbao-server common_name=localhost ip_sans=127.0.0.1 > .runtime/issue.json
```

## Switch to OpenBao issued certificate

```sh
jq -r .data.certificate .runtime/issue.json > tls/server.pem
jq -r .data.private_key .runtime/issue.json > tls/server-key.pem
pkill -HUP -f 'bao server -config openbao.d'
export BAO_CACERT=$PWD/tls/ca.pem
bao status
```

## Re-Verify the handshake

```sh
openssl s_client -connect 127.0.0.1:8200 -CAfile tls/ca.pem </dev/null \
  | grep -E 'Peer signature type|Negotiated TLS1.3 group|Verification'
# both of these must fail
openssl s_client -connect 127.0.0.1:8200 -CAfile tls/ca.pem -groups X25519 </dev/null
openssl s_client -connect 127.0.0.1:8200 -CAfile tls/ca.pem -tls1_2 </dev/null
```

## Reset to start over

```sh
pkill -f 'bao server -config openbao.d'
rm -rf .runtime tls
# restore bootstrap certificates
git restore .
```
