# Generate a Base64-encoded secret
generate_base64_secret() {
  local length=$1
  openssl rand -base64 "$length"
}

generate_base32_secret() {
  local length=$1

  # Generate 40 random bytes
  secret=$(openssl rand -hex 40)

  # Convert the hexadecimal bytes to binary
  binary_secret=$(echo -n "$secret" | xxd -r -p)

  # Encode the secret in Base32
  encoded_secret=$(echo -n "$binary_secret" | base32)

  # Truncate or pad to get exactly 64 characters
  encoded_secret=${encoded_secret:0:64}
  while [ ${#encoded_secret} -lt 64 ]; do
      encoded_secret+="="
  done

  echo "$encoded_secret"
}

# Generate random bytes, encode in Base64, then extract a part of the encoded string.
mix_phx_gen() {
  local length=$1
  # Generate random bytes and encode in Base64
  local encoded=$(openssl rand -base64 "$length")
  # Remove padding (if needed) and truncate to the desired length
  echo "${encoded//=/}" | cut -c 1-"$length"
}

# Default length for Base64 secrets
length=32

# Name of the file to create
filenameEnv=".env.vault"
filenameK8SSecret=".env.vault.k8s.secret"

JWT_SECRET_KEY=$(generate_base64_secret $length)
AES_SECRET_KEY=$(generate_base64_secret $length)
SECRET_KEY_BASE=$(mix_phx_gen "64")
RELEASE_COOKIE=$(generate_base64_secret "40")

  # Create a .env file and create secrets
  {

    echo "JWT_SECRET_KEY: '$JWT_SECRET_KEY'"
    echo "AES_SECRET_KEY: '$AES_SECRET_KEY'"
    echo "SECRET_KEY_BASE: '$SECRET_KEY_BASE'"
    echo "RELEASE_COOKIE: '$RELEASE_COOKIE'"
    echo ""
  } > "$filenameEnv"

  echo "$filenameEnv file generated, it contains base64 encoded values"

  {

echo "---
apiVersion: v1
kind: Secret
metadata:
  name: vault-secrets
type: Opaque
data:
  JWT_SECRET_KEY: $(echo -n $JWT_SECRET_KEY | base64)
  AES_SECRET_KEY: $(echo -n $AES_SECRET_KEY | base64)
  SECRET_KEY_BASE: $(echo -n $SECRET_KEY_BASE | base64)
  RELEASE_COOKIE: $(echo -n $RELEASE_COOKIE | base64)"

    } > "$filenameK8SSecret"

    echo "$filenameK8SSecret file generated"
