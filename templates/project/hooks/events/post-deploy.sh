#!/usr/bin/env bash
# post-deploy hook — docker compose up 之后执行
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/../env/load-env.sh"

# ── Cloudflare Tunnel 公网发布（取消注释启用） ──
# 1. ~/.forge/config/.forge 配置 CF_API_TOKEN CF_ACCOUNT_ID CF_TUNNEL_ID CF_ZONE_ID
# 2. load-env.sh 中 export DOMAIN="$APP_NAME.oneblue.dev"
# 3. 取消下面注释：
# source "$DIR/../plugins/cloudflare.sh"
# cf_route_add "$DOMAIN" "http://localhost:<内部端口>"
# ── 部署后逻辑在此添加 ──
# ── 在此处添加部署后逻辑 ──
