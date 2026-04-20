#!/bin/bash
set -e

CONFIG_DIR="/root/.paperclip/instances/default"

rm -f "$CONFIG_DIR/config.json"

mkdir -p "$CONFIG_DIR/secrets"
mkdir -p "$CONFIG_DIR/logs"
mkdir -p "$CONFIG_DIR/data/storage"

if [ ! -f "$CONFIG_DIR/secrets/master.key" ]; then
  openssl rand -hex 32 > "$CONFIG_DIR/secrets/master.key"
fi

cat > "$CONFIG_DIR/config.json" <<EOF
{
  "\$meta": {
    "version": 1,
    "updatedAt": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)",
    "source": "configure"
  },
  "database": { "mode": "postgres" },
  "logging": { "mode": "file", "logDir": "/root/.paperclip/instances/default/logs" },
  "server": {
    "deploymentMode": "authenticated",
    "exposure": "public",
    "host": "0.0.0.0",
    "port": 3100,
    "bind": "lan",
    "allowedHostnames": ["hq.sohob.co.uk"],
    "serveUi": true
  },
  "auth": {
    "baseUrlMode": "explicit",
    "publicBaseUrl": "https://hq.sohob.co.uk",
    "disableSignUp": false
  },
  "storage": {
    "provider": "local_disk",
    "localDiskRoot": "/root/.paperclip/instances/default/data/storage"
  },
  "secrets": {
    "provider": "local_encrypted",
    "keyFilePath": "/root/.paperclip/instances/default/secrets/master.key",
    "strictMode": false
  },
  "telemetry": { "enabled": false }
}
EOF

exec pnpm paperclipai run
