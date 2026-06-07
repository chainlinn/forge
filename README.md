# forge

CLI 工具，一条命令完成 GitHub 仓库 + Docker Hub 仓库创建、CI/CD Secrets 注册、部署流水线生成。专为 **Tailscale + Docker Compose** 部署架构设计。

![cli init](static/cli_init.gif)

```
$ forge init my-app          # 创建 GitHub 仓库 + Docker Hub 仓库 + CI/CD
$ git push origin main       # 触发构建 → 推送镜像 → Tailscale 部署到 NAS
$ forge sync                 # 更新 Secrets
$ forge destroy my-app       # 远程容器清理 → 删除仓库 → 删除本地
```

## 安装

```bash
brew tap chainlinn/tap
brew install forge-cli
```

**前提：** `gh`、`jq`、`curl`、`git` 已安装，且 `gh auth login` 已认证。

## 快速开始

### 1. 准备凭证文件

```bash
mkdir -p ~/.forge/config
cat > ~/.forge/config/.secrets <<'EOF'
TS_OAUTH_CLIENT_ID=your_tailscale_client_id
TS_OAUTH_SECRET=your_tailscale_oauth_secret
TS_TAGS=tag:ci
DOCKERHUB_USERNAME=your_dockerhub_username
DOCKERHUB_TOKEN=your_dockerhub_token
DEPLOY_HOST=your.nas.host
DEPLOY_USER=ubuntu
DEPLOY_SSH_KEY_BASE64=$(base64 < ~/.ssh/id_ed25519)
DEPLOY_ROOT=/home/ubuntu/deploy/apps
EOF
```

> `_BASE64` 后缀的值在注册 GitHub Secret 时会自动解码。GitHub Secret 收到的是原始 PEM 密钥，不是 base64 字符串。

### 2. 创建项目

```bash
forge init my-app --port 9000
```

### 3. 写 Dockerfile 和业务代码

### 4. 推送触发部署

```bash
git push origin main
```

GitHub Actions 自动：构建镜像 → 推送到 Docker Hub → Tailscale 连接 NAS → SCP + SSH 部署。

## 命令

### `forge init [name]`

在当前目录创建项目脚手架。带 `name` 参数时先建目录。

```bash
forge init                       # 当前目录，自动分配端口
forge init my-api                # mkdir ./my-api + 初始化
forge init my-api --port 9000    # 指定端口
forge init my-api --visibility public
```

**生成文件：**

```
my-api/
├── Dockerfile              # nginx:1.27-alpine
├── docker-compose.yml      # image + ports + volumes
├── index.html              # 部署状态页面（timeline 展示全流程）
├── .gitignore
└── .github/workflows/
    └── deploy.yml          # Build → Push → Tailscale → Deploy
```

### `forge sync`

将本地 `.secrets` 同步到已存在的 GitHub 仓库 Secrets。

```bash
forge sync                          # 自动检测当前 git remote
forge sync --name owner/repo        # 指定仓库
```

### `forge destroy [name]`

三阶段清理：

```
Phase 1: GitHub Actions 远程清理（SSH 进 NAS → docker compose down → rm -rf）
Phase 2: 删除 GitHub 仓库 + Docker Hub 仓库
Phase 3: 删除本地目录
```

```bash
forge destroy my-api        # 删远程仓库 + rm -rf ./my-api
forge destroy               # 删除当前目录对应的项目
```

## 选项

| 选项 | 说明 | 默认值 |
|------|------|--------|
| `--port PORT` | 宿主机端口映射 | 8889 起自动分配（`FORGE_PORT_START` 可覆盖） |
| `--name NAME` | GitHub 仓库名 | 当前目录名 |
| `--visibility TYPE` | GitHub 仓库可见性 | `private` |
| `--secrets PATH` | `.secrets` 文件路径 | `~/.forge/config/.secrets` → 回退 `./.secrets` |

## 模板

`forge init` 使用的模板位于：

| 安装方式 | 模板路径 |
|----------|----------|
| Homebrew | `/opt/homebrew/share/forge/templates/shared/` |
| 手动 | `~/.forge/templates/shared/`（首次运行自动 bootstrap） |

可替换模板文件来定制生成内容：

```
templates/shared/
├── Dockerfile
├── docker-compose.yml
├── deploy.yml
├── cleanup.yml
└── index.html
```

模板使用 `{{变量}}` 占位符：`{{IMAGE_NAME}}` `{{CONTAINER_NAME}}` `{{HOST_PORT}}` `{{CONTAINER_PORT}}` `{{DEPLOY_ROOT}}`。

## 端口管理

端口分配记录在 `~/.forge/ports`，格式 `project:port`。`init` 从 `PORT_START`（默认 8889）起找第一个空闲端口，`destroy` 自动释放。

```bash
# 自定义起始端口
FORGE_PORT_START=10000 forge init my-app
```

## 部署架构

```
本地 / CI
  forge init         → GitHub Repo + Secrets
  git push           → GitHub Actions 触发

GitHub Actions
  docker build       → 构建镜像
  docker push        → Docker Hub
  tailscale/github-action → 连接 NAS
  scp-action         → 拷贝 compose 文件
  ssh-action         → docker compose up -d
```

## License

MIT
