#!/bin/sh
rm -rf /etc/nginx/ssl
mkdir -p /etc/nginx/ssl

# ========================================
# 1. Création de la CA (Autorité de Certification)
# ========================================
openssl genrsa -out /etc/nginx/ssl/ca.key 4096

openssl req -new -x509 \
  -key /etc/nginx/ssl/ca.key \
  -out /etc/nginx/ssl/ca.crt \
  -days 3650 \
  -subj "/C=FR/ST=France/O=Portfolio CA/CN=Portfolio Root CA"

# ========================================
# 2. Création de la clé + CSR du serveur
# ========================================
openssl genrsa -out /etc/nginx/ssl/nginx.key 2048

openssl req -new \
  -key /etc/nginx/ssl/nginx.key \
  -out /etc/nginx/ssl/nginx.csr \
  -subj "/C=FR/ST=France/O=Portfolio/CN=portfolio-service"

# ========================================
# 3. Extensions SAN
# ========================================
cat > /tmp/san.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage=digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName=DNS:portfolio-service,DNS:localhost,IP:127.0.0.1
EOF

# ========================================
# 4. Signature du certificat par la CA
# ========================================
openssl x509 -req \
  -in /etc/nginx/ssl/nginx.csr \
  -CA /etc/nginx/ssl/ca.crt \
  -CAkey /etc/nginx/ssl/ca.key \
  -CAcreateserial \
  -out /etc/nginx/ssl/nginx.crt \
  -days 365 \
  -extfile /tmp/san.ext

# ========================================
# 5. Permissions
# ========================================
chmod 600 /etc/nginx/ssl/nginx.key /etc/nginx/ssl/ca.key
chmod 644 /etc/nginx/ssl/nginx.crt /etc/nginx/ssl/ca.crt

# Nettoyage
rm -f /etc/nginx/ssl/nginx.csr /tmp/san.ext