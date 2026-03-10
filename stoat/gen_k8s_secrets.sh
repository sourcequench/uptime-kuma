#!/usr/bin/env bash
DOMAIN="stoat.sourcequench.org"
VIDEO_ENABLED=true

# Generate VAPID keys
openssl ecparam -name prime256v1 -genkey -noout -out vapid_private.pem
PUSHD_VAPID_PRIVATEKEY=$(base64 -i vapid_private.pem | tr -d '\n' | tr -d '=')
PUSHD_VAPID_PUBLICKEY=$(openssl ec -in vapid_private.pem -outform DER|tail --bytes 65|base64|tr '/+' '_-'|tr -d '\n'|tr -d '=')
rm vapid_private.pem

# Generate files encryption key
FILES_ENCRYPTION_KEY=$(openssl rand -base64 32)

# Generate Livekit secrets
LIVEKIT_WORLDWIDE_SECRET=$(openssl rand -hex 24)
LIVEKIT_WORLDWIDE_KEY=$(openssl rand -hex 6)

# Create Kubernetes Secret (NOT to be added to Git)
cat <<EOF > stoat/k8s/stoat-secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: stoat-secrets
  namespace: stoat
type: Opaque
stringData:
  PUSHD_VAPID_PRIVATEKEY: "$PUSHD_VAPID_PRIVATEKEY"
  PUSHD_VAPID_PUBLICKEY: "$PUSHD_VAPID_PUBLICKEY"
  FILES_ENCRYPTION_KEY: "$FILES_ENCRYPTION_KEY"
  LIVEKIT_WORLDWIDE_KEY: "$LIVEKIT_WORLDWIDE_KEY"
  LIVEKIT_WORLDWIDE_SECRET: "$LIVEKIT_WORLDWIDE_SECRET"
  RABBITMQ_PASSWORD: "rabbitpass"
  MINIO_ROOT_PASSWORD: "minioautumn"
EOF

# Create Revolt.toml (Template with placeholders for ENV substitution or similar)
# Note: For Stoat to read these from Env, the binary must support it or we use a templating entrypoint.
# For now, we'll keep the generated TOML/YML but remind the user to .gitignore them or use secrets.

cat <<EOF > stoat/Revolt.toml
[hosts]
app = "https://$DOMAIN"
api = "https://$DOMAIN/api"
events = "wss://$DOMAIN/ws"
autumn = "https://$DOMAIN/autumn"
january = "https://$DOMAIN/january"

[hosts.livekit]
worldwide = "wss://$DOMAIN/livekit"

[pushd.vapid]
private_key = "$PUSHD_VAPID_PRIVATEKEY"
public_key = "$PUSHD_VAPID_PUBLICKEY"

[files]
encryption_key = "$FILES_ENCRYPTION_KEY"

[api.livekit.nodes.worldwide]
url = "http://livekit:7880"
lat = 0.0
lon = 0.0
key = "$LIVEKIT_WORLDWIDE_KEY"
secret = "$LIVEKIT_WORLDWIDE_SECRET"
EOF

# Create livekit.yml
cat <<EOF > stoat/livekit.yml
rtc:
  use_external_ip: true
  port_range_start: 50000
  port_range_end: 50100
  tcp_port: 7881

redis:
  address: redis:6379

turn:
  enabled: false

keys:
  $LIVEKIT_WORLDWIDE_KEY: $LIVEKIT_WORLDWIDE_SECRET

webhook:
  api_key: $LIVEKIT_WORLDWIDE_KEY
  urls:
  - "http://voice-ingress:8500/worldwide"
EOF

# Create .env.web
cat <<EOF > stoat/env.web
HOSTNAME=https://$DOMAIN
REVOLT_PUBLIC_URL=https://$DOMAIN/api
VITE_API_URL=https://$DOMAIN/api
VITE_WS_URL=wss://$DOMAIN/ws
VITE_MEDIA_URL=https://$DOMAIN/autumn
VITE_PROXY_URL=https://$DOMAIN/january
VITE_CFG_ENABLE_VIDEO=$VIDEO_ENABLED
EOF

echo "Generated config and secrets in stoat/ and stoat/k8s/"
echo "CRITICAL: Do NOT commit stoat/k8s/stoat-secrets.yaml to Git."
