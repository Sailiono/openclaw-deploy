---
name: openclaw-deploy
description: |
  One-shot OpenClaw full-stack deployment on a fresh Ubuntu/Debian server via SSH.
  Handles USTC mirrors, mihomo/Clash proxy, Node.js, Docker, OpenClaw Gateway,
  model provider setup, WeChat Bot, and Feishu Bot. All secrets are parameterized
  — nothing is hardcoded. Designed for batch provisioning of multiple machines.
metadata:
  type: skill
  target_os: [ubuntu-22.04, ubuntu-24.04, debian-12, debian-13]
  target_arch: [amd64, arm64]
version: 1.1.0
---

# OpenClaw 全自动部署 Skill

> 从 SSH 到一台全新 Ubuntu/Debian 机器开始，完成 OpenClaw 日用环境部署。
> 所有密钥、订阅链接、密码均为参数，不内置任何真实 secret。

---

## 用法

向 Claude Code 发送本 Skill 后，先填写"部署参数区"中的变量，然后直接执行。

```
/openclaw-deploy
```

Claude Code 会按 17 个阶段顺序执行，每阶段验证后继续。

---

## 阶段 -1：部署参数填写区

**执行前必须填好以下变量。已填好的值不会被重复索取。**

极重要：
- 不要把任何 secret 原样打印到终端或报告
- 所有 secret 只允许显示打码形式（前6位 + `***` + 后4位）
- Secret 文件权限必须是 600 或更严格
- 报告中只写 secret 存储路径，不写内容

### A. SSH / 远程连接参数

```bash
# 执行模式：
#   already_in_ssh：已经在目标机器上
#   ssh_connect：需要 Claude Code 先 SSH 连接
EXECUTION_MODE="ssh_connect"

# 目标机器 SSH 信息（ssh_connect 模式必填）
SSH_HOST=""
SSH_PORT="22"
SSH_USER="root"

# 认证方式：key / password
SSH_AUTH_METHOD="password"

# SSH key 路径（key 模式时使用）
SSH_KEY_PATH=""

# SSH 密码（password 模式时使用，建议部署后轮换）
SSH_PASSWORD=""

# 是否允许使用 sshpass（password 模式时建议 true）
ALLOW_SSHPASS_FOR_PASSWORD_LOGIN="true"
```

### B. sudo / 系统权限参数

```bash
# 远程用户的 sudo 密码（免密 sudo 则留空）
SUDO_PASSWORD=""

# 是否启用 systemd user linger（SSH 场景推荐 true）
ENABLE_SYSTEMD_LINGER="true"
```

### C. 国内网络 / Clash 订阅参数

```bash
# 是否安装 mihomo / Clash.Meta 代理核心
INSTALL_MIHOMO="true"

# Clash 订阅链接（secret，绝对不要打印）
CLASH_SUB_URL=""

# mihomo 本机代理端口
MIHOMO_MIXED_PORT="7890"
MIHOMO_EXTERNAL_CONTROLLER="127.0.0.1:9090"
MIHOMO_ALLOW_LAN="false"
MIHOMO_ENABLE_TUN="false"

# 安装过程中是否临时启用代理
USE_PROXY_DURING_INSTALL="true"

# 是否设置 git 全局代理
SET_GIT_PROXY="true"

# npm/pnpm 是否走代理（默认 false，优先 USTC/npmmirror 镜像）
SET_NPM_PROXY="false"
```

### D. 镜像加速参数

```bash
# ============================================================
# 镜像源选择 — 根据服务器地理位置选择最快的镜像站
# ============================================================
# 预设：
#   auto    — 自动测速选择（推荐）
#   ustc    — 中国科学技术大学（合肥，华东/华中快）
#   tsinghua— 清华大学 TUNA（北京，华北快）
#   aliyun  — 阿里云（杭州，华东/全国快）
#   nju     — 南京大学（南京，华东快）
#   sjtu    — 上海交通大学（上海，华东快）
#   bfsu    — 北京外国语大学（北京，华北快）
#   tencent — 腾讯云（广州，华南快）
#   huawei  — 华为云（全国快，不限地域）
#   direct  — 不换源，使用官方源（海外服务器）
# ============================================================
MIRROR_PRESET="auto"

# APT 镜像 URL（auto 模式会自动测速选择，manual 模式手动填写）
# auto 模式下留空即可，部署时会自动检测最快的镜像站
APT_MIRROR=""

# 是否将 security 源也换到镜像站（可能有同步延迟）
MIRROR_SECURITY_SOURCE="true"

# PyPI 镜像（auto 模式自动匹配）
PIP_INDEX=""

# npm 镜像（USTC 反代或 npmmirror）
NPM_REGISTRY=""
NPM_FALLBACK_REGISTRY="https://registry.npmmirror.com"

# Docker 镜像加速器（auto 模式自动匹配，逗号分隔）
DOCKER_MIRRORS=""

# Node.js 下载镜像（npmmirror 在国内可直接访问）
NODE_MIRROR="https://npmmirror.com/mirrors/node"
```

**镜像站速查表：**

| 预设 | 镜像站 | APT | PyPI | npm | Docker | 推荐地区 |
|------|--------|-----|------|-----|--------|----------|
| `ustc` | 中科大 | mirrors.ustc.edu.cn | ✅ | ✅ | ✅ | 合肥/华东/华中 |
| `tsinghua` | 清华 TUNA | mirrors.tuna.tsinghua.edu.cn | ✅ | ❌ | ✅ | 北京/华北 |
| `aliyun` | 阿里云 | mirrors.aliyun.com | ✅ | ❌ | ✅ | 杭州/全国 |
| `nju` | 南京大学 | mirrors.nju.edu.cn | ✅ | ❌ | ✅ | 南京/华东 |
| `sjtu` | 上海交大 | mirrors.sjtug.sjtu.edu.cn | ✅ | ❌ | ✅ | 上海/华东 |
| `bfsu` | 北外 | mirrors.bfsu.edu.cn | ✅ | ❌ | ❌ | 北京/华北 |
| `tencent` | 腾讯云 | mirrors.tencent.com | ❌ | ❌ | ❌ | 广州/华南 |
| `huawei` | 华为云 | mirrors.huaweicloud.com | ✅ | ❌ | ❌ | 全国 |
| `direct` | 官方源 | archive.ubuntu.com / deb.debian.org | ❌ | ❌ | ❌ | 海外 |

> **建议**：华东地区优先 `ustc`/`nju`，华北优先 `tsinghua`/`bfsu`，华南优先 `tencent`/`aliyun`。
> `auto` 模式会自动 ping 测速选最快的。海外服务器直接用 `direct`。

### E. LLM Provider 配置

```bash
# Provider 类型：opencode / openai / anthropic / custom
PROVIDER_TYPE="opencode"

# ---- OpenCode Go ----
OPENCODE_API_KEY=""
OPENCODE_API_ENDPOINT="https://opencode.ai/zen/go/v1"

# ---- OpenAI 兼容 ----
OPENAI_API_KEY=""
OPENAI_BASE_URL=""
# 如果是 OpenRouter 等代理，填写提供商名称
OPENAI_PROVIDER_NAME=""

# ---- Anthropic ----
ANTHROPIC_API_KEY=""

# ---- 自定义 Provider（OpenAI 兼容） ----
CUSTOM_API_KEY=""
CUSTOM_BASE_URL=""
CUSTOM_PROVIDER_NAME=""

# 默认模型层级
DEFAULT_MODEL_TIER="performance"

# 性能层（默认主力）
PRIMARY_MODEL=""
FALLBACK_MODELS=""  # JSON 数组，如 ["model-a","model-b"]

# 是否使用 OpenClaw 原生 fallback
USE_NATIVE_FALLBACK="true"
```

### F. 微信 ClawBot 参数

```bash
CONFIGURE_WECHAT="true"

# DM 安全策略：pairing / allowlist / open
WECHAT_DM_POLICY="pairing"

# 群聊安全策略
WECHAT_GROUP_POLICY="allowlist"
WECHAT_REQUIRE_MENTION="true"

# allowlist（微信 peer id，未知可留空，后续从 logs 识别）
WECHAT_ALLOW_FROM=""
WECHAT_GROUP_ALLOW_FROM=""
```

### G. 飞书 Bot 参数

```bash
CONFIGURE_FEISHU="false"

FEISHU_DOMAIN="feishu"
FEISHU_CONNECTION_MODE="websocket"

FEISHU_APP_ID=""
FEISHU_APP_SECRET=""  # secret

FEISHU_DM_POLICY="pairing"
FEISHU_GROUP_POLICY="allowlist"
FEISHU_REQUIRE_MENTION="true"

FEISHU_ALLOW_FROM=""
FEISHU_GROUP_ALLOW_FROM=""
```

### H. OpenClaw 参数

```bash
INSTALL_OPENCLAW="true"

OPENCLAW_WORKSPACE="$HOME/.openclaw/workspace"
OPENCLAW_GATEWAY_HOST="127.0.0.1"
OPENCLAW_GATEWAY_PORT="18789"

# Gateway daemon
INSTALL_OPENCLAW_DAEMON="true"

# 安全策略
OPENCLAW_DM_POLICY="pairing"
OPENCLAW_GROUP_POLICY="allowlist"
OPENCLAW_REQUIRE_MENTION="true"
OPENCLAW_SANDBOX_MODE="non-main"
```

### I. 自动化行为

```bash
# 非关键失败是否继续后续阶段
CONTINUE_ON_NON_CRITICAL_FAILURE="true"

# 最终生成文件路径
SETUP_REPORT_PATH="$HOME/openclaw-setup-report.md"
DAILY_OPS_PATH="$HOME/openclaw-daily-ops.md"
OPENCLAW_STATUS_SCRIPT="$HOME/bin/openclaw-status"
MIHOMO_STATUS_SCRIPT="$HOME/bin/mihomo-status"
```

---

## 阶段 0：SSH 连接和会话保护

### 0.1 连接模式处理

若 `EXECUTION_MODE="already_in_ssh"`：
- 检查当前环境：`whoami && hostname && uname -a`
- 记录到报告

若 `EXECUTION_MODE="ssh_connect"`：
- 检查本机是否有 `sshpass`（password 模式需要）
- 若没有则尝试安装：`apt install -y sshpass` 或 `brew install sshpass` 或使用 paramiko
- 连接到目标：`ssh -p $SSH_PORT $SSH_USER@$SSH_HOST`
- 连接成功后所有操作在远程执行

### 0.2 sudo 验证

```bash
# 若 SUDO_PASSWORD 非空
printf '%s\n' "$SUDO_PASSWORD" | sudo -S -v

# 若为空
sudo -v  # 会提示手动输入
```

### 0.3 tmux 会话保护

```bash
# 安装 tmux（若没有）
command -v tmux || sudo apt update && sudo apt install -y tmux

# 创建或 attach 会话
tmux new-session -d -s openclaw-setup 2>/dev/null || true
# 若当前不在 tmux 中，提示用户执行:
# tmux attach -t openclaw-setup
```

### 0.4 创建目录和打码工具

```bash
mkdir -p ~/openclaw-setup-logs ~/bin ~/.openclaw
chmod 700 ~/.openclaw

# 创建打码 sed 脚本
cat > ~/bin/redact-secrets << 'EOF'
#!/usr/bin/env bash
sed -E \
  -e 's#(https?://[^/? ]+)[^ ]*#\1/***REDACTED***#g' \
  -e 's/(sk-[A-Za-z0-9._-]{6})[A-Za-z0-9._-]+([A-Za-z0-9._-]{4})/\1***REDACTED***\2/g' \
  -e 's/(Authorization:[[:space:]]*Bearer[[:space:]]+)[A-Za-z0-9._-]+/\1***REDACTED***/gi' \
  -e 's/(appSecret["'\'' ]*[:=][ "'\''"]*)[^"'\'' ,}]+/\1***REDACTED***/gi'
EOF
chmod +x ~/bin/redact-secrets
```

### 0.5 创建报告

```bash
cat > ~/openclaw-setup-report.md << EOF
# OpenClaw 部署报告
开始时间：$(date)
用户：$(whoami)  主机：$(hostname)
目录：$(pwd)
EOF
```

---

## 阶段 1：系统环境体检

```bash
# 检测 OS
cat /etc/os-release
# 提取 ID (ubuntu/debian) 和 VERSION_ID (22.04/24.04/12/13)
OS_ID="$(. /etc/os-release && echo "${ID}")"
OS_VERSION="$(. /etc/os-release && echo "${VERSION_ID}")"
OS_CODENAME="$(. /etc/os-release && echo "${VERSION_CODENAME}")"

# 架构
ARCH="$(dpkg --print-architecture)"

# 记录系统信息到报告
echo "OS: $OS_ID $OS_VERSION ($OS_CODENAME) arch=$ARCH" >> ~/openclaw-setup-report.md
uname -a >> ~/openclaw-setup-report.md
df -h >> ~/openclaw-setup-report.md
free -h >> ~/openclaw-setup-report.md
```

**适配逻辑：**

| OS | 代号 | 架构 | APT 镜像路径 | 备注 |
|----|------|------|-------------|------|
| Ubuntu 24.04 | noble | amd64 | `/ubuntu` | DEB822 格式优先 |
| Ubuntu 24.04 | arm64 | arm64 | `/ubuntu-ports` | ports 镜像 |
| Ubuntu 22.04 | jammy | amd64 | `/ubuntu` | 传统 sources.list |
| Ubuntu 22.04 | arm64 | arm64 | `/ubuntu-ports` | ports 镜像 |
| Debian 13 | trixie | amd64 | `/debian` | DEB822 格式 (deb822) |
| Debian 13 | arm64 | arm64 | `/debian-ports` | ports 镜像 |
| Debian 12 | bookworm | amd64 | `/debian` | DEB822 或传统格式 |
| Debian 12 | arm64 | arm64 | `/debian-ports` | ports 镜像 |

---

## 阶段 2：换源

### 2.1 判断源文件格式

```bash
# Ubuntu 24.04+ 和 Debian 13+ 默认使用 DEB822 格式
if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then
  SOURCE_FORMAT="deb822"
  SOURCE_FILE="/etc/apt/sources.list.d/ubuntu.sources"
elif [ -f /etc/apt/sources.list.d/debian.sources ]; then
  SOURCE_FORMAT="deb822"
  SOURCE_FILE="/etc/apt/sources.list.d/debian.sources"
else
  SOURCE_FORMAT="legacy"
  SOURCE_FILE="/etc/apt/sources.list"
fi
```

### 2.2 备份并替换

```bash
# 备份
APT_BAK="/etc/apt/backup-before-openclaw-$(date +%Y%m%d-%H%M%S)"
sudo mkdir -p "$APT_BAK"
sudo cp -a /etc/apt/sources.list "$APT_BAK/" 2>/dev/null || true
sudo cp -a /etc/apt/sources.list.d "$APT_BAK/" 2>/dev/null || true
```

**Ubuntu amd64 示例：**
```bash
sudo sed -i -E \
  -e 's#https?://(archive|cn.archive).ubuntu.com/ubuntu/?#https://mirrors.ustc.edu.cn/ubuntu#g' \
  -e 's#https?://security.ubuntu.com/ubuntu/?#https://mirrors.ustc.edu.cn/ubuntu#g' \
  /etc/apt/sources.list.d/ubuntu.sources  # 或 /etc/apt/sources.list
```

**Debian amd64 示例：**
```bash
sudo sed -i -E \
  -e 's#https?://deb.debian.org/debian/?#https://mirrors.ustc.edu.cn/debian#g' \
  -e 's#https?://security.debian.org/debian-security/?#https://mirrors.ustc.edu.cn/debian-security#g' \
  /etc/apt/sources.list
```

### 2.3 验证

```bash
sudo apt clean && sudo apt update  # 失败则停止，检查源文件
```

### 2.4 安装最小依赖

```bash
sudo apt install -y curl wget jq gzip tar ca-certificates openssl \
  gnupg lsb-release software-properties-common apt-transport-https \
  python3 python3-pip python3-venv tmux unzip
```

---

## 阶段 3：mihomo / Clash 代理

### 3.1 获取 mihomo 最新版本

```bash
ARCH="$(dpkg --print-architecture)"
case "$ARCH" in
  amd64) MIHOMO_ARCH="linux-amd64" ;;
  arm64) MIHOMO_ARCH="linux-arm64" ;;
  armhf) MIHOMO_ARCH="linux-armv7" ;;
  *) echo "Unsupported arch: $ARCH"; exit 1 ;;
esac

# 从 GitHub API 获取最新 release（可能需要代理）
RELEASE_JSON="$(curl -fsSL --connect-timeout 30 \
  https://api.github.com/repos/MetaCubeX/mihomo/releases/latest)"

MIHOMO_URL="$(echo "$RELEASE_JSON" | jq -r --arg arch "$MIHOMO_ARCH" '
  .assets[] | select(.name | test($arch))
  | select(.name | endswith(".gz"))
  | select(.name | contains("compatible") | not)
  | .browser_download_url' | head -1)"
```

### 3.2 下载和安装

```bash
cd /tmp && mkdir -p mihomo_install && cd mihomo_install
curl -fL "$MIHOMO_URL" -o mihomo.gz
gunzip mihomo.gz && chmod +x mihomo
./mihomo -v
sudo install -m 0755 mihomo /usr/local/bin/mihomo
```

### 3.3 下载订阅并配置

```bash
sudo mkdir -p /etc/mihomo && sudo chmod 700 /etc/mihomo

# 保存订阅链接（权限 600）
sudo tee /etc/mihomo/subscription.url >/dev/null << EOF
$CLASH_SUB_URL
EOF
sudo chmod 600 /etc/mihomo/subscription.url

# 下载配置
sudo bash -c 'curl -fL --connect-timeout 30 --retry 3 \
  -H "User-Agent: clash-verge/v2.0.0" \
  "$(cat /etc/mihomo/subscription.url)" \
  -o /etc/mihomo/config.yaml'
chmod 600 /etc/mihomo/config.yaml
```

### 3.4 安全改写配置（Python）

```python
import yaml, pathlib, shutil, time, os

path = pathlib.Path("/etc/mihomo/config.yaml")
backup = pathlib.Path(f"/etc/mihomo/config.yaml.bak.{time.strftime('%Y%m%d-%H%M%S')}")
shutil.copy2(path, backup)

with path.open("r", encoding="utf-8", errors="ignore") as f:
    cfg = yaml.safe_load(f) or {}

MIHOMO_SECRET = os.environ.get("MIHOMO_SECRET", os.popen("openssl rand -hex 24").read().strip())

cfg["mixed-port"] = 7890
cfg["allow-lan"] = False
cfg["bind-address"] = "127.0.0.1"
cfg["mode"] = cfg.get("mode") or "rule"
cfg["log-level"] = "info"
cfg["external-controller"] = "127.0.0.1:9090"
cfg["secret"] = MIHOMO_SECRET
cfg["ipv6"] = False
cfg.pop("port", None)
cfg.pop("socks-port", None)

# 国内环境无法下载 MMDB 时的 fallback
cfg["geodata-mode"] = False

# 移除需要 MMDB 的 GEOIP 规则
if "rules" in cfg:
    cfg["rules"] = [r for r in cfg["rules"]
        if not (isinstance(r, str) and r.startswith("GEOIP,"))
        and not (isinstance(r, dict) and r.get("type") == "GEOIP")]

with path.open("w", encoding="utf-8") as f:
    yaml.safe_dump(cfg, f, allow_unicode=True, sort_keys=False)
```

### 3.5 systemd 服务

```bash
sudo tee /etc/systemd/system/mihomo.service >/dev/null << 'EOF'
[Unit]
Description=mihomo Daemon, Clash.Meta compatible proxy core
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
Group=root
LimitNOFILE=1000000
ExecStart=/usr/local/bin/mihomo -d /etc/mihomo
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=3
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=full
ProtectHome=read-only
ReadWritePaths=/etc/mihomo

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now mihomo
```

### 3.6 验证

```bash
# 检查端口（必须只监听 127.0.0.1）
ss -lntp | grep -E ':(7890|9090)'
# 预期: 127.0.0.1:7890 和 127.0.0.1:9090
# 若出现 0.0.0.0 立即停止修复！

# 代理测试
curl -I --connect-timeout 15 -x http://127.0.0.1:7890 https://github.com
```

### 3.7 临时启用代理

```bash
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
export no_proxy=localhost,127.0.0.1,::1,mirrors.ustc.edu.cn

# Git 代理
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890
```

---

## 阶段 4：基础依赖和 pip 加速

```bash
sudo apt install -y git curl wget jq unzip gzip tar ca-certificates gnupg \
  lsb-release build-essential python3 python3-pip python3-venv \
  software-properties-common apt-transport-https net-tools iproute2 \
  dnsutils procps htop make gcc g++ pkg-config openssl

# pip USTC 镜像
mkdir -p ~/.pip
cat > ~/.pip/pip.conf << EOF
[global]
index-url = ${PIP_INDEX}
trusted-host = $(echo $PIP_INDEX | sed 's|https://||;s|/.*||')
timeout = 120
EOF
```

---

## 阶段 5：Node.js / npm / pnpm

### 5.1 判断安装策略

优先使用 npmmirror 直接下载 Node.js 二进制（国内免代理）:
```bash
NODE_VERSION="24.11.1"  # 执行时检查最新 LTS
NODE_URL="https://npmmirror.com/mirrors/node/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz"

# 下载、解压、安装
curl -fL --connect-timeout 60 --max-time 300 "$NODE_URL" -o /tmp/node.tar.xz
cd /tmp && tar -xJf node.tar.xz
sudo cp -r node-v*-linux-x64/* /usr/local/
/usr/local/bin/node -v  # 必须 >= 22.16
```

### 5.2 配置 npm/pnpm

```bash
# npm 镜像
npm config set registry "$NPM_REGISTRY"
npm ping || npm config set registry "$NPM_FALLBACK_REGISTRY"

# pnpm
npm install -g pnpm@latest
pnpm config set registry "$(npm config get registry)"
```

---

## 阶段 6：Docker（可选）

```bash
# Docker CE 仓库 — 根据 OS 自动选择路径
DOCKER_OS="ubuntu"  # Debian 使用 "debian"
[[ "$OS_ID" == "debian" ]] && DOCKER_OS="debian"

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL "https://mirrors.ustc.edu.cn/docker-ce/linux/${DOCKER_OS}/gpg" | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] \
  https://mirrors.ustc.edu.cn/docker-ce/linux/${DOCKER_OS} $OS_CODENAME stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list

sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin

# 镜像加速
sudo tee /etc/docker/daemon.json >/dev/null << EOF
{
  "registry-mirrors": [$(echo "$DOCKER_MIRRORS" | sed 's/,/","/g' | sed 's/^/"/;s/$/"/')],
  "log-driver": "json-file",
  "log-opts": {"max-size": "100m", "max-file": "3"}
}
EOF

sudo systemctl restart docker
sudo usermod -aG docker "$USER"
```

---

## 阶段 7：OpenClaw 安装

```bash
# 用户级 npm 全局前缀
mkdir -p ~/.local/npm-global
npm config set prefix ~/.local/npm-global
export PATH="$HOME/.local/npm-global/bin:$PATH"
echo 'export PATH="$HOME/.local/npm-global/bin:$PATH"' >> ~/.bashrc

# 安装 OpenClaw
npm install -g openclaw@latest
openclaw --version
```

### 7.1 配置 Gateway

```bash
openclaw config set gateway.mode local
openclaw config set gateway.bind loopback
openclaw config set gateway.port "$OPENCLAW_GATEWAY_PORT"

# Workspace
mkdir -p ~/.openclaw/workspace/{inbox,outputs,scripts,logs,tmp,projects,skills}
openclaw config set agents.defaults.workspace "$OPENCLAW_WORKSPACE"
```

### 7.2 安装 Gateway daemon

```bash
openclaw gateway install
openclaw gateway start

# 启用 linger（SSH 断线后服务继续运行）
sudo loginctl enable-linger "$USER"
```

验证：`openclaw gateway status` 应显示 `Reachable: yes`

---

## 阶段 8：Provider 和模型配置

### 8.1 OpenCode Go（内置 Provider）

OpenClaw 2026.5+ 内置 `@openclaw/opencode-go-provider`，无需额外安装。

```bash
# 保存 API key
umask 077
cat > ~/.openclaw/opencode.env << EOF
OPENCODE_API_KEY=${OPENCODE_API_KEY}
EOF
chmod 600 ~/.openclaw/opencode.env

# systemd 环境注入
mkdir -p ~/.config/systemd/user/openclaw-gateway.service.d
cat > ~/.config/systemd/user/openclaw-gateway.service.d/opencode-env.conf << 'EOF'
[Service]
EnvironmentFile=%h/.openclaw/opencode.env
EOF
systemctl --user daemon-reload
```

### 8.2 模型和 Fallback 配置

```bash
# 主力模型
openclaw config set agents.defaults.model.primary "$PRIMARY_MODEL"

# Fallback 链（JSON 数组）
openclaw config set agents.defaults.model.fallbacks "$FALLBACK_MODELS" --strict-json
```

### 8.3 自定义 Provider

```bash
# 如果 PROVIDER_TYPE=custom，通过环境变量注入
cat > ~/.openclaw/custom.env << EOF
OPENAI_API_KEY=${CUSTOM_API_KEY}
OPENAI_BASE_URL=${CUSTOM_BASE_URL}
EOF
chmod 600 ~/.openclaw/custom.env
```

### 8.4 重启生效

```bash
systemctl --user daemon-reload
openclaw gateway restart
openclaw models list  # 验证模型可用
```

---

## 阶段 9：微信 ClawBot

### 9.1 安装插件

```bash
# @tencent-weixin/openclaw-weixin 已内置为可安装通道
npm install -g @tencent-weixin/openclaw-weixin@latest
openclaw plugins install @tencent-weixin/openclaw-weixin
```

### 9.2 配置通道

```bash
openclaw config set channels.openclaw-weixin.enabled true
openclaw config set channels.openclaw-weixin.dmPolicy "$WECHAT_DM_POLICY"
openclaw config set channels.openclaw-weixin.groupPolicy "$WECHAT_GROUP_POLICY"
openclaw config set channels.openclaw-weixin.requireMention "$WECHAT_REQUIRE_MENTION"
```

### 9.3 扫码登录

```bash
openclaw gateway restart
openclaw channels login --channel openclaw-weixin
# 终端会显示 ASCII QR 码和链接，用微信扫描
```

### 9.4 获取用户 ID 并配置 allowlist

```bash
# 发一条消息后查日志
journalctl --user -u openclaw-gateway.service -n 50 --no-pager | \
  grep "config cached for" | tail -1
# 输出示例: config cached for o9cq80z5qWvcYiZp4t4r4tD3VjkQ@im.wechat

# 将用户 ID 加入 allowlist
openclaw config set channels.openclaw-weixin.allowFrom '["<your-wechat-id>"]' --strict-json
openclaw gateway restart
```

---

## 阶段 10：飞书 Bot

> **零基础用户请先阅读**：[`feishu-bot-guide.md`](feishu-bot-guide.md)
> 该教程手把手带你完成飞书开放平台的所有配置步骤。

```bash
# 仅当 CONFIGURE_FEISHU=true 时执行

openclaw config set channels.feishu.enabled true
openclaw config set channels.feishu.domain "$FEISHU_DOMAIN"
openclaw config set channels.feishu.connectionMode "$FEISHU_CONNECTION_MODE"
openclaw config set channels.feishu.dmPolicy "$FEISHU_DM_POLICY"
openclaw config set channels.feishu.groupPolicy "$FEISHU_GROUP_POLICY"
openclaw config set channels.feishu.requireMention "$FEISHU_REQUIRE_MENTION"

# App Secret 通过 wizard 交互输入
openclaw channels login --channel feishu
```

---

## 阶段 11：创建状态脚本

```bash
cat > ~/bin/openclaw-status << 'STATUSEOF'
#!/usr/bin/env bash
set -euo pipefail
redact() {
  sed -E -e 's#(https?://[^/? ]+)[^ ]*#\1/***REDACTED***#g' \
    -e 's/(sk-[A-Za-z0-9._-]{6})[A-Za-z0-9._-]+([A-Za-z0-9._-]{4})/\1***REDACTED***\2/g'
}
PATH="/usr/local/bin:$HOME/.local/npm-global/bin:$PATH"
echo "===== OpenClaw Status $(date) ====="
echo "System: $(hostname) $(lsb_release -ds 2>/dev/null || true)"
echo "openclaw: $(openclaw --version 2>/dev/null || echo N/A)"
echo "node: $(node -v 2>/dev/null)  docker: $(docker --version 2>/dev/null)"
echo "mihomo: $(/usr/local/bin/mihomo -v 2>/dev/null)"
echo
systemctl status mihomo --no-pager 2>&1 | redact | head -5
openclaw gateway status 2>&1 | redact | head -10
openclaw models list 2>&1 | redact | head -10
STATUSEOF
chmod +x ~/bin/openclaw-status

# mihomo 状态脚本同理
cat > ~/bin/mihomo-status << 'MIHOMOSTATUSEOF'
#!/usr/bin/env bash
set -euo pipefail
redact() { sed -E -e 's#(https?://[^/? ]+)[^ ]*#\1/***REDACTED***#g'; }
echo "===== mihomo $(/usr/local/bin/mihomo -v) ====="
systemctl status mihomo --no-pager | redact
ss -lntp | grep -E ':(7890|9090)'
curl -I --connect-timeout 10 -x http://127.0.0.1:7890 https://github.com 2>&1 | redact | head -5
journalctl -u mihomo -n 30 --no-pager | redact
MIHOMOSTATUSEOF
chmod +x ~/bin/mihomo-status
```

---

## 阶段 12：生成运维文档

创建 `~/openclaw-daily-ops.md`，包含：
- SSH/tmux 重连方法
- 各服务启动/停止/重启命令
- 日志查看路径
- 模型切换方法
- 微信/飞书故障排查
- 备份/恢复步骤
- 安全停用/卸载步骤

---

## 阶段 13：最终验收

验收清单：
- [ ] 系统环境（OS 版本、架构、时区）
- [ ] USTC 镜像（apt / pip / npm / Docker）
- [ ] mihomo 代理（端口、监听地址、代理测试）
- [ ] Node.js（版本 >= 22.16）
- [ ] Docker（版本、hello-world）
- [ ] OpenClaw Gateway（daemon、监听地址）
- [ ] Provider 配置（API key 打码、模型列表、fallback）
- [ ] 微信通道（登录状态、收发测试）
- [ ] 飞书通道（如启用）
- [ ] 安全检查（无公网暴露、DM pairing、secrets 权限）
- [ ] 状态脚本可用
- [ ] 运维文档完整

---

## 执行原则

1. **每个阶段必须验证**，不跳过检查
2. **每次改配置前先备份**
3. **Secret 不打印、不入 shell history、不入报告**，只写打码形式
4. **命令失败先读错误、查 help、查文档**，不盲目重试
5. **若某项因版本/网络/权限无法完成**，明确写：
   - 已完成什么
   - 卡在哪里
   - 需要用户做什么
   - 下一步怎么继续
6. **适配 OS 差异**：
   - Ubuntu 24.04: DEB822 格式 (`ubuntu.sources`)，noble
   - Ubuntu 22.04: 传统格式 (`sources.list`)，jammy
   - Debian 13: DEB822 格式 (`debian.sources`)，trixie
   - Debian 12: 传统或 DEB822 格式，bookworm
   - Docker 仓库路径：Ubuntu 用 `/docker-ce/linux/ubuntu`，Debian 用 `/docker-ce/linux/debian`
   - 所有 Debian 版本 security 源路径为 `debian-security`，不含版本代号
7. **适配架构**：
   - amd64: `/ubuntu` 或 `/debian`
   - arm64: `/ubuntu-ports` 或 `/debian-ports`

---

## 参考文档（执行时重新验证）

- OpenClaw: https://github.com/openclaw/openclaw
- OpenClaw 安装: https://docs.openclaw.ai/install
- OpenCode Go Provider: https://docs.openclaw.ai/providers/opencode-go
- Model Failover: https://docs.openclaw.ai/concepts/model-failover
- USTC 镜像: https://mirrors.ustc.edu.cn/help/
- mihomo: https://wiki.metacubex.one/
- Tencent Weixin Plugin: https://github.com/Tencent/openclaw-weixin
- OpenClaw Feishu: https://docs.openclaw.ai/channels/feishu
