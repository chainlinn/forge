#!/usr/bin/env bash
# post-cleanup hook — 在 NAS 上 docker compose down + rm -rf 之后执行
# 工作目录: $APP_DIR/docker/compose（此时可能已不存在）
# 可用变量: APP_NAME, APP_DIR
set -euo pipefail

# 在此处添加清理后逻辑
# 例如：从 Cloudflare/反向代理 移除路由、清理外部资源
