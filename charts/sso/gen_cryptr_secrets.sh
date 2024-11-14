#!/bin/bash

# Fonction pour générer un secret encodé en Base64
generate_base64_secret() {
  local length=$1
  openssl rand -base64 "$length"
}

# Génère des octets aléatoires, les encode en Base64, puis extrait une partie de la chaîne encodée.
mix_phx_gen() {
  local length=$1
  # Générer des octets aléatoires et encoder en Base64
  local encoded=$(openssl rand -base64 "$length")
  # Retirer le padding (si nécessaire) et tronquer à la longueur souhaitée
  echo "${encoded//=/}" | cut -c 1-"$length"
}

# Longueur par défaut des secrets Base64
length=32

# Nom du fichier à créer
filenameEnv=".env.cryptr"
filenameK8S=".env.cryptr.k8s.secret"

AES_SECRET_KEY=$(generate_base64_secret $length)
API_KEY_SECRET_BASE=$(generate_base64_secret $length)
SANDBOX_API_KEY_PEPPER=$(generate_base64_secret $length)
SANDBOX_API_KEY_SECRET_BASE=$(generate_base64_secret $length)
CLIENT_SECRET_SALT=$(generate_base64_secret $length)
TENANT_API_SECRET_KEY=$(generate_base64_secret $length)
DIR_SYNC_SECRET_BASE=$(generate_base64_secret $length)
SANDBOX_DIR_SYNC_SECRET_BASE=$(generate_base64_secret $length)
DIRECTORY_SYNC_PEPPER=$(mix_phx_gen "64")
SECRET_KEY_BASE=$(mix_phx_gen "64")
SERVICE_MANAGER_SECRET=$(generate_base64_secret $length)

  # Create a .env file
  {
    echo "AES_SECRET_KEY: '$AES_SECRET_KEY'"
    echo "API_KEY_SECRET_BASE: '$API_KEY_SECRET_BASE'"
    echo "SANDBOX_API_KEY_PEPPER: '$SANDBOX_API_KEY_PEPPER'"
    echo "SANDBOX_API_KEY_SECRET_BASE: '$SANDBOX_API_KEY_SECRET_BASE'"
    echo "CLIENT_SECRET_SALT: '$CLIENT_SECRET_SALT'"
    echo "TENANT_API_SECRET_KEY: '$TENANT_API_SECRET_KEY'"
    echo "DIR_SYNC_SECRET_BASE: '$DIR_SYNC_SECRET_BASE'"
    echo "SANDBOX_DIR_SYNC_SECRET_BASE: '$SANDBOX_DIR_SYNC_SECRET_BASE'"
    echo "DIRECTORY_SYNC_PEPPER: '$DIRECTORY_SYNC_PEPPER'"
    echo "SECRET_KEY_BASE: '$SECRET_KEY_BASE'"
    echo "SERVICE_MANAGER_SECRET: '$SERVICE_MANAGER_SECRET'"
  } > "$filenameEnv"

  echo "File $filenameEnv generated."

  {

    # Create a k8s secret file file
echo "---
apiVersion: v1
kind: Secret
metadata:
  name: cryptr-secrets
type: Opaque
data:
    AES_SECRET_KEY: $(echo -n $AES_SECRET_KEY | base64)
    API_KEY_SECRET_BASE: $(echo -n $API_KEY_SECRET_BASE | base64)
    SANDBOX_API_KEY_PEPPER: $(echo -n $SANDBOX_API_KEY_PEPPER | base64)
    SANDBOX_API_KEY_SECRET_BASE: $(echo -n $SANDBOX_API_KEY_SECRET_BASE | base64)
    CLIENT_SECRET_SALT: $(echo -n $CLIENT_SECRET_SALT | base64)
    TENANT_API_SECRET_KEY: $(echo -n $TENANT_API_SECRET_KEY | base64)
    DIR_SYNC_SECRET_BASE: $(echo -n $DIR_SYNC_SECRET_BASE | base64)
    SANDBOX_DIR_SYNC_SECRET_BASE: $(echo -n $SANDBOX_DIR_SYNC_SECRET_BASE | base64)
    DIRECTORY_SYNC_PEPPER: $(echo -n $DIRECTORY_SYNC_PEPPER | base64)
    SECRET_KEY_BASE: $(echo -n $SECRET_KEY_BASE | base64)
    SERVICE_MANAGER_SECRET: $(echo -n $SERVICE_MANAGER_SECRET | base64)"
    } > "$filenameK8S"

    echo "File $filenameK8S generated."
