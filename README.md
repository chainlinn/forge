<div align="center">

# forge

**通过 GitHub Actions + Tailscale 安全隧道，一键将代码部署到你的私有服务器。**

[![License: MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![Version](https://img.shields.io/badge/version-0.1.1-6366f1)](https://github.com/chainlinn/forge/releases)

![demo](static/demo.gif)

[安装](#安装) · [快速开始](#快速开始) · [命令](#命令) · [架构](#架构) · [钩子系统](#钩子系统)

</div>

---

## 解决什么问题

你有台 NAS 或 VPS 放在家里/办公室，没有公网 IP，但想把代码一键部署上去。

传统做法：手动建 GitHub 仓库 → 手动建 Docker Hub 仓库 → 手动配 Secrets → 手写 CI/CD → 配 Tailscale → 配 SCP → 配 SSH。七个步骤，每一步都可能出错。

**forge 一条命令搞定全部。** Tailscale 隧道穿透内网，GitHub Actions 自动构建镜像、推送到 Docker Hub、SCP 拷贝 compose 文件、SSH 远程拉起容器。你只需要 `git push`。

## 安装

```bash
brew tap chainlinn/tap
brew install forge-cli
```

前提：`gh` `jq` `curl` `git` 已安装，`gh auth login` 已认证。

## 快速开始

```bash
# 1. 准备凭证（一次性）
mkdir -p ~/.forge/config && cp /path/to/.secrets ~/.forge/config/.secrets

# 2. 创建项目
forge init my-api --port 9000

# 3. 推送 → 自动构建、推送镜像、部署到 NAS
git push origin main
```

## 命令

### `forge init [name]`

```bash
forge init                    # 当前目录，自动分配端口
forge init my-api             # mkdir ./my-api + 初始化
forge init my-api --port 9000 --visibility public
```

### `forge sync`

将 `.secrets` 同步到 GitHub Secrets。

```bash
forge sync                       # 自动检测当前 git remote
forge sync --name owner/repo
```

### `forge destroy [name]`

四阶段清理：Cloudflare 下架 → NAS 清理 → 远程仓库 → 本地目录。

```bash
forge destroy my-api
forge destroy
```

## 架构

```
项目                forge 仓库（逻辑集中维护）

.github/workflows/
  deploy.yml  ───→  chainlinn/forge/.github/workflows/deploy.yml@v0.1.1
  cleanup.yml ───→  chainlinn/forge/.github/workflows/cleanup.yml@v0.1.1
                   secrets: inherit  # 全量透传，零配置
```

deploy.yml 只有 9 行，永不修改。升级 forge 改 tag 即可。

## 钩子系统

```
forge/hooks/
├── env/
│   └── load-env.sh          # 环境变量（默认值 + 非敏感导出）
├── events/
│   ├── pre-deploy.sh        # 部署前
│   ├── post-deploy.sh       # 部署后
│   ├── pre-cleanup.sh       # 销毁前
│   └── post-cleanup.sh      # 销毁后
└── plugins/
    └── cloudflare.sh        # Cloudflare Tunnel 路由管理
```

所有钩子在 NAS 上执行，`secrets: inherit` 全量透传 GitHub Secrets。

**添加 Cloudflare 公网发布：**

1. `.secrets` 加 `CF_API_TOKEN` `CF_ACCOUNT_ID` `CF_TUNNEL_ID` `CF_ZONE_ID`
2. `env/load-env.sh` 加 `export DOMAIN="$APP_NAME.oneblue.dev"`
3. `events/post-deploy.sh` 取消注释：
   ```bash
   source "$DIR/../plugins/cloudflare.sh"
   cf_route_add "$DOMAIN" "http://localhost:<端口>"
   ```
4. `events/pre-cleanup.sh` 取消注释：
   ```bash
   source "$DIR/../plugins/cloudflare.sh"
   cf_route_del "$DOMAIN"
   ```

`forge sync` 一次，后续所有项目自动生效。

## 选项

| 选项 | 说明 | 默认值 |
|------|------|--------|
| `--port PORT` | 宿主机端口 | 8889 起自动分配 |
| `--name NAME` | GitHub 仓库名 | 当前目录名 |
| `--visibility TYPE` | GitHub 仓库可见性 | `private` |
| `--secrets PATH` | `.secrets` 路径 | `~/.forge/config/.secrets` |

`PORT_START` 可通过环境变量覆盖：

```bash
FORGE_PORT_START=10000 forge init my-api
```

## 模板

`forge init` 从模板目录渲染生成文件。占位符：`{{IMAGE_NAME}}` `{{CONTAINER_NAME}}` `{{HOST_PORT}}` `{{CONTAINER_PORT}}` `{{DEPLOY_ROOT}}`。

| 安装方式 | 模板路径 |
|----------|----------|
| Homebrew | `/opt/homebrew/share/forge/templates/` |
| 手动 | `~/.forge/templates/`（首次运行自动 bootstrap） |

```
templates/
├── project/              # Dockerfile, compose, index.html, hooks/
└── workflows/            # deploy.yml, cleanup.yml（薄封装）
```

## 技术栈

| 组件 | 用途 |
|------|------|
| GitHub CLI | 仓库创建 + Secrets 管理 |
| GitHub Actions | CI/CD（reusable workflow） |
| Tailscale | 安全隧道连接 NAS |
| Docker + Compose | 构建、推送、运行 |
| Docker Hub | 镜像托管 |

## 路线图

- [x] `forge init` — 项目脚手架
- [x] `forge sync` — Secrets 同步
- [x] `forge destroy` — 多阶段销毁
- [x] 端口自动分配与追踪
- [x] 生命周期钩子（env / events / plugins）
- [x] Reusable workflow 架构
- [x] Homebrew 分发
- [ ] 多模板支持（Go、Python、Node.js）

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.
