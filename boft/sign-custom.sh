#!/bin/sh
# Signs boft/custom.json into boft/custom.txt the way read_custom_client (src/common.rs) reads it:
# base64(ed25519 signature (64 bytes) || the JSON), checked against KEY there. The key is the Ed25519 private key
# (PEM) kept off this repo; usage: boft/sign-custom.sh <key.pem>
set -eu
key=$1; here=$(dirname "$0"); t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
python3 -I -c 'import json,sys; sys.stdout.write(json.dumps(json.load(open(sys.argv[1])), separators=(",", ":")))' "$here/custom.json" > "$t/msg"
openssl pkeyutl -sign -inkey "$key" -rawin -in "$t/msg" -out "$t/sig"
cat "$t/sig" "$t/msg" | base64 | tr -d '\n' > "$here/custom.txt"
pub=$(openssl pkey -in "$key" -pubout -outform DER | tail -c 32 | base64)
grep -q "const KEY: &str = \"$pub\"" "$here/../src/common.rs" || { echo "KEY in src/common.rs is not this key's" >&2; exit 1; }
echo "boft/custom.txt signed ($(wc -c < "$here/custom.txt") bytes)"
