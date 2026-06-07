<div align="center">

# forge

**通过 GitHub Actions + Tailscale 安全隧道，一键将代码部署到你的私有服务器。**

[![License: MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![Version](https://img.shields.io/badge/version-0.1.0-6366f1)](https://github.com/chainlinn/forge/releases)

![demo](static/demo.gif)

[安装](#安装) · [快速开始](#快速开始) · [命令](#命令) · [模板](#模板) · [部署架构](#部署架构)

</div>

---

## 解决什么问题

你有台 NAS 或 VPS 放在家里/办公室，没有公网 IP，但想把代码一键部署上去。

传统做法：手动建 GitHub 仓库 → 手动建 Docker Hub 仓库 → 手动配 Secrets → 手写 CI/CD → 配 Tailscale → 配 SCP → 配 SSH。七个步骤，每一步都可能出错。

**forge 一条命令搞定全部。** Tailscale 隧道穿透内网，GitHub Actions 自动构建镜像、推送到 Docker Hub、SCP 拷贝 compose 文件、SSH 远程拉起容器。你只需要 `git push`。

## 功能

| 能力 | 说明 |
|------|------|
| 仓库创建 | `gh repo create` + Docker Hub repo（`docker push` 自动建） |
| Secrets 同步 | `.secrets` 全量注册到 GitHub Secrets，`_BASE64` 自动解码 |
| 脚手架生成 | Dockerfile + compose + deploy.yml + 部署状态页 |
| 端口管理 | 自动分配/冲突检测/销毁释放，`~/.forge/ports` 追踪 |
| 一键销毁 | CI 远程清理 NAS 容器 → 删远程仓库 → 删本地目录 |

## 安装

```bash
brew tap chainlinn/tap
brew install forge-cli
```

**前提：** `gh`、`jq`、`curl`、`git` 已安装，`gh auth login` 已认证。

## 快速开始

```bash
# 1. 准备凭证（一次性）
mkdir -p ~/.forge/config && cp /path/to/.secrets ~/.forge/config/.secrets

# 2. 创建项目
forge init my-api --port 9000

# 3. 写 Dockerfile + 业务代码，然后推送
git push origin main
```

<details>
<summary>.secrets 文件格式</summary>

```
TS_OAUTH_CLIENT_ID=...
TS_OAUTH_SECRET=...
TS_TAGS=tag:ci
DOCKERHUB_USERNAME=...
DOCKERHUB_TOKEN=...
DEPLOY_HOST=...
DEPLOY_USER=ubuntu
DEPLOY_SSH_KEY_BASE64=$(base64 < ~/.ssh/id_ed25519)
DEPLOY_ROOT=/home/ubuntu/deploy/apps
```

> `_BASE64` 后缀的值在注册 GitHub Secret 时自动解码为原始 PEM。

</details>

## 命令

### `forge init [name]`

在目标目录生成项目脚手架。

```bash
forge init                    # 当前目录，自动分配端口
forge init my-api             # mkdir ./my-api + 初始化
forge init my-api --port 9000 --visibility public
```

**生成文件：**

```
my-api/
├── Dockerfile              # nginx:1.27-alpine
├── docker-compose.yml      # image + ports + volumes
├── index.html              # 部署状态页（timeline 展示全流程）
└── .github/workflows/
    └── deploy.yml          # Build → Push → Tailscale → Deploy
```

### `forge sync`

将本地 `.secrets` 增量同步到 GitHub Secrets。

```bash
forge sync                       # 自动检测当前 git remote
forge sync --name owner/repo     # 指定仓库
```

### `forge destroy [name]`

三阶段优雅清理：

1. **远程清理** — 通过 GitHub Actions SSH 进 NAS 执行 `docker compose down` + `rm -rf`
2. **删除仓库** — `gh repo delete` + Docker Hub API delete
3. **删除本地** — `rm -rf` 项目目录

```bash
forge destroy my-api    # 删远程仓库 + 本地目录
forge destroy           # 当前目录对应的项目
```

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

`forge init` 从模板目录渲染生成文件。模板使用 `{{变量}}` 占位符。

| 安装方式 | 模板路径 |
|----------|----------|
| Homebrew | `/opt/homebrew/share/forge/templates/shared/` |
| 手动 | `~/.forge/templates/shared/`（首次运行自动 bootstrap） |

```
templates/shared/
├── Dockerfile
├── docker-compose.yml
├── deploy.yml
├── cleanup.yml
└── index.html
```

占位符：`{{IMAGE_NAME}}` `{{CONTAINER_NAME}}` `{{HOST_PORT}}` `{{CONTAINER_PORT}}` `{{DEPLOY_ROOT}}`

## 部署架构

```
$ forge init my-api       → GitHub Repo + Secrets + 脚手架
$ git push origin main    → GitHub Actions 触发

GitHub Actions
  ├─ docker build + push  → 构建镜像 → Docker Hub
  ├─ tailscale/github-action → Tailscale 隧道连接 NAS
  ├─ scp-action           → 拷贝 compose 文件到 $DEPLOY_ROOT
  └─ ssh-action           → docker compose pull && up -d
```

## 技术栈

| 组件 | 用途 |
|------|------|
| GitHub CLI (`gh`) | 仓库创建 + Secrets 管理 |
| GitHub Actions | CI/CD 执行引擎 |
| Tailscale | 安全隧道连接 NAS |
| Docker | 构建 + 运行 |
| Docker Compose | 容器编排 |
| Docker Hub | 镜像托管 |

## 路线图

- [x] `forge init` — 项目脚手架
- [x] `forge sync` — Secrets 同步
- [x] `forge destroy` — 三阶段销毁
- [x] 端口自动分配与追踪
- [x] Homebrew 分发
- [ ] 多模板支持（Go、Python、Node.js）
- [ ] 交互式 `forge init`（问答式配置）

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.
