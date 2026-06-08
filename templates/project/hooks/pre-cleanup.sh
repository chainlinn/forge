#!/usr/bin/env bash
# pre-cleanup hook — docker compose down 之前执行
# 环境变量: APP_NAME, APP_DIR
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

# ── 示例：从 Cloudflare Tunnel 下架 ──
# source "$DIR/lib/cloudflare.sh"
# cf_route_del "$APP_NAME.oneblue.dev"

# ── 在此处添加清理前逻辑 ──
