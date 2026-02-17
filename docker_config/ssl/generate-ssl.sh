#!/bin/sh
mkdir -p /etc/nginx/ssl

# La CA vient du Secret Kubernetes monté dans /etc/nginx/ca/
CA_CRT=/etc/nginx/ca/ca.crt
CA_KEY=/etc/nginx/ca/ca.key

# Clé privée du serveur
openssl genrsa -out /etc/nginx/ssl/nginx.key 2048

# CSR
openssl req -new \
  -key /etc/nginx/ssl/nginx.key \
  -out /tmp/nginx.csr \
  -subj "/C=FR/ST=France/O=Portfolio/CN=portfolio-service"

# Extensions SAN
cat > /tmp/san.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage=digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName=DNS:portfolio-service,DNS:localhost,IP:127.0.0.1
EOF

# Signature par la CA fixe
openssl x509 -req \
  -in /tmp/nginx.csr \
  -CA $CA_CRT \
  -CAkey $CA_KEY \
  -CAcreateserial \
  -out /etc/nginx/ssl/nginx.crt \
  -days 365 \
  -extfile /tmp/san.ext

# Fullchain = cert serveur + CA
cat /etc/nginx/ssl/nginx.crt $CA_CRT > /etc/nginx/ssl/fullchain.crt

chmod 600 /etc/nginx/ssl/nginx.key
chmod 644 /etc/nginx/ssl/nginx.crt /etc/nginx/ssl/fullchain.crt

rm -f /tmp/nginx.csr /tmp/san.ext