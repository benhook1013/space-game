#!/usr/bin/env bash

# Generates a throwaway self-signed TLS keypair for local development.
# The key is written to .dev/certs/dev-key.pem and the certificate to
# .dev/certs/dev-cert.pem. Both are ignored by git.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CERT_DIR="${ROOT_DIR}/.dev/certs"
KEY_PATH="${CERT_DIR}/dev-key.pem"
CERT_PATH="${CERT_DIR}/dev-cert.pem"
DAYS_VALID="${DEV_CERT_DAYS:-365}"

if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl is required to generate a dev certificate" >&2
  exit 1
fi

if [[ -f "${KEY_PATH}" && -f "${CERT_PATH}" ]]; then
  echo "Dev certificate already present at ${CERT_PATH}"
  exit 0
fi

mkdir -p "${CERT_DIR}"

openssl req \
  -x509 \
  -nodes \
  -newkey rsa:2048 \
  -keyout "${KEY_PATH}" \
  -out "${CERT_PATH}" \
  -days "${DAYS_VALID}" \
  -subj "/CN=localhost" \
  -addext "subjectAltName = DNS:localhost,IP:127.0.0.1" \
  -addext "basicConstraints = CA:false" \
  -addext "keyUsage = digitalSignature,keyEncipherment" \
  -addext "extendedKeyUsage = serverAuth"

echo "Created dev key: ${KEY_PATH}"
echo "Created dev cert: ${CERT_PATH}"
echo "Set DEV_CERT_DAYS to adjust validity (current: ${DAYS_VALID} days)."
