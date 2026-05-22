# OpenClaw Deploy

一键在全新 Ubuntu/Debian 服务器上完成 OpenClaw 全栈部署。

从 SSH 登录开始，自动完成换源、代理、依赖、OpenClaw Gateway、模型配置、微信 Bot、飞书 Bot，最终验收交付。

---

## 支持的系统

| OS | 版本 | 架构 |
|----|------|------|
| Ubuntu | 22.04 / 24.04 | amd64 / arm64 |
| Debian | 12 / 13 | amd64 / arm64 |

## 做了什么

- **多镜像源智能选择** — 中科大、清华、阿里云、腾讯云等 9 个镜像源可选，auto 模式自动测速
- **mihomo / Clash 代理** — 导入订阅，本机 127.0.0.1:7890，不暴露公网
- **Node.js + pnpm** — Node 24.x，npmmirror 直连下载
- **Docker CE** — 国内镜像加速器
- **OpenClaw Gateway** — daemon 化，loopback 监听，配好 workspace
- **多 Provider 支持** — OpenCode Go / OpenAI / Anthropic / 自定义，多模型 fallback 链
- **微信 ClawBot** — 扫码登录，DM pairing，群聊 requireMention
- **飞书 Bot** — WebSocket 长连接，无需公网 IP，配[零基础教程](feishu-bot-guide.md)
- **状态脚本 + 运维文档** — `openclaw-status` / `mihomo-status` / 日用 ops 指南

---

## 快速开始

```bash
# 1. Clone
git clone https://github.com/Sailiono/openclaw-deploy.git
cd openclaw-deploy

# 2. 运行检测脚本，查看适合你的使用方式
./deploy.sh          # macOS / Linux
# 或
.\deploy.ps1         # Windows PowerShell
```

脚本会自动检测你安装了哪些 AI 工具，并给出对应的使用指导。

### 跨平台 / 跨工具使用

| AI 工具 | 使用方式 |
|---------|---------|
| **Claude Code CLI** | `claude` 进入会话后 `@SKILL.md` |
| **Claude Desktop** | File → Open Project → 选择本目录 |
| **VS Code Copilot** | 打开目录，Chat 中 `@workspace` 引用 SKILL.md |
| **Cursor / Windsurf** | 打开目录，Ctrl+L 输入 `@SKILL.md` |
| **GitHub Copilot CLI** | `gh copilot suggest` 后粘贴 SKILL.md |
| **OpenAI Codex CLI** | `codex exec` 后粘贴 SKILL.md |
| **通用（任意工具）** | 打开 SKILL.md → 填参数 → 全选复制 → 粘贴到 AI 对话 |

---

## 你需要准备的

- 服务器的 SSH 登录信息（IP、端口、用户、密码或 key）
- Clash 订阅链接（可选，海外服务器可跳过）
- LLM API Key（OpenCode Go / OpenAI / Anthropic / 自定义）
- 微信账号（可选，扫码登录）
- 飞书开发者账号（可选，参考 [`feishu-bot-guide.md`](feishu-bot-guide.md)）

## 镜像源选择

支持 9 个国内镜像源 + 海外直连，按服务器地理位置选择或 `auto` 自动测速：

| 预设 | 镜像站 | 推荐地区 |
|------|--------|----------|
| `ustc` | 中科大 | 合肥 / 华东 / 华中 |
| `tsinghua` | 清华 TUNA | 北京 / 华北 |
| `aliyun` | 阿里云 | 杭州 / 全国 |
| `nju` | 南京大学 | 南京 / 华东 |
| `sjtu` | 上海交大 | 上海 / 华东 |
| `bfsu` | 北外 | 北京 / 华北 |
| `tencent` | 腾讯云 | 广州 / 华南 |
| `huawei` | 华为云 | 全国 |
| `direct` | 官方源 | 海外 |

## 安全原则

- 所有密钥 / 密码 / 订阅链接均为参数，不内置任何真实 secret
- Gateway 仅监听 127.0.0.1，不暴露公网
- mihomo 代理本机 only，allow-lan=false
- 私聊默认 pairing 审批，群聊默认 requireMention + allowlist
- Secret 文件权限 600，日志和报告自动脱敏

## 目录结构

```
├── SKILL.md                    # 主部署 Skill（13 阶段）
├── feishu-bot-guide.md         # 飞书零基础接入教程
├── deploy.sh                   # 使用检测脚本 (macOS/Linux)
├── deploy.ps1                  # 使用检测脚本 (Windows)
├── README.md
└── scripts/
    ├── mihomo-config-rewrite.sh    # mihomo 配置安全改写
    ├── openclaw-status.sh          # 状态检查脚本模板
    └── redact-secrets.sh           # 日志脱敏工具
```

## 适用范围

- 国内网络环境（镜像 + Clash 代理）
- 海外 VPS（关闭代理，直连官方源）
- 个人日用、小团队共享、批量装机

---

## 其他需求？

有 bug、新功能建议、适配其他系统或 AI 工具？欢迎 [提 Issue](https://github.com/Sailiono/openclaw-deploy/issues)。
