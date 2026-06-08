#!/usr/bin/env bash
# post-deploy hook — 在 NAS 上 docker compose up 之后执行
# 工作目录: $APP_DIR/docker/compose
# 可用变量: APP_NAME, APP_DIR
set -euo pipefail

# 在此处添加部署后逻辑
# 例如：健康检查、通知
