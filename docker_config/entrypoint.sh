#!/bin/sh

# Génération du certificat signé par la CA (montée via Secret K8s)
echo "Génération du certificat SSL..."
/usr/local/bin/generate-ssl.sh

if [ $? -ne 0 ]; then
    echo "Erreur lors de la génération du certificat SSL"
    exit 1
fi

echo "Certificat généré, démarrage de nginx..."
exec nginx -g "daemon off;"