#!/usr/bin/env bash
# pre-cleanup hook — 在 NAS 上 docker compose down 之前执行
# 工作目录: $APP_DIR/docker/compose
# 可用变量: APP_NAME, APP_DIR
set -euo pipefail

# 在此处添加清理前逻辑
# 例如：备份数据库、通知外部服务
