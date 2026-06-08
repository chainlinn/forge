#!/usr/bin/env bash
# post-deploy hook — docker compose up 之后执行
# 环境变量: APP_NAME, APP_DIR, DATA_DIR
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

# ── 示例：发布到 Cloudflare Tunnel ──
# 1. 在 deploy.yml 的 SSH 段 export CF_API_TOKEN CF_ACCOUNT_ID CF_TUNNEL_ID CF_ZONE_ID
# 2. 取消下面注释：
# source "$DIR/lib/cloudflare.sh"
# cf_route_add "$APP_NAME.oneblue.dev" "http://localhost:<内部端口>"

# ── 在此处添加部署后逻辑 ──
