# forge

一键创建 GitHub + Docker Hub 仓库，自动注册 CI/CD Secrets，生成部署流水线模板。

## 安装

```bash
brew tap chainlinn/tap
brew install forge
```

或手动安装：

```bash
mkdir -p ~/.local/bin
cp bin/forge ~/.local/bin/forge
chmod +x ~/.local/bin/forge
cp -r templates ~/.forge/templates
```

## 快速开始

```bash
# 1. 准备 .secrets 文件
mkdir -p ~/.forge/config
cat > ~/.forge/config/.secrets <<'EOF'
TS_OAUTH_CLIENT_ID=your_tailscale_client_id
TS_OAUTH_SECRET=your_tailscale_oauth_secret
TS_TAGS=tag:ci
DOCKERHUB_USERNAME=your_dockerhub_username
DOCKERHUB_TOKEN=your_dockerhub_access_token
DEPLOY_HOST=your.server.com
DEPLOY_USER=ubuntu
DEPLOY_SSH_KEY_BASE64=your_base64_encoded_private_key
DEPLOY_ROOT=/home/user/deploy/apps
EOF

# 2. 登录 GitHub CLI
gh auth login

# 3. 创建项目
forge init my-app

# 4. 写 Dockerfile 和业务代码
# 5. 推送触发部署
git push origin main
```

## 命令

| 命令 | 说明 |
|------|------|
| `forge init [name]` | 创建项目：GitHub 仓库 + Docker Hub 仓库 + Secrets + CI/CD 模板 |
| `forge sync` | 同步本地 `.secrets` 到 GitHub Secrets |
| `forge destroy [name]` | 三阶段清理：远程部署 → 远程仓库 → 本地目录 |

## 选项

| 选项 | 说明 | 默认值 |
|------|------|--------|
| `--port PORT` | 宿主机端口 | 8889 起自动分配 |
| `--name NAME` | 仓库名 | 当前目录名 |
| `--visibility TYPE` | GitHub 仓库可见性 | private |
| `--secrets PATH` | `.secrets` 路径 | `~/.forge/config/.secrets` |
| `-h, --help` | 帮助 | - |

## 模板

`forge init` 为项目生成以下文件：

```
my-app/
├── Dockerfile
├── docker-compose.yml
├── index.html
├── README.md
└── .github/
    └── workflows/
        └── deploy.yml
```

模板位于 `templates/shared/`，可自定义。

## License

MIT
