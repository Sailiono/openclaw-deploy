# OpenClaw Deploy

一键在全新 Ubuntu/Debian 服务器上完成 OpenClaw 全栈部署。

从 SSH 登录开始，自动完成换源、代理、依赖、OpenClaw Gateway、模型配置、微信 Bot、飞书 Bot，最终验收交付。

## 支持的系统

| OS | 版本 | 架构 |
|----|------|------|
| Ubuntu | 22.04 / 24.04 | amd64 / arm64 |
| Debian | 12 / 13 | amd64 / arm64 |

## 做了什么

- **USTC 国内镜像换源** — apt、pip、npm、Docker 全切到中科大镜像
- **mihomo / Clash 代理** — 导入订阅，本机 127.0.0.1:7890，不暴露公网
- **Node.js + pnpm** — Node 24.x，npmmirror 直连下载
- **Docker CE** — 国内镜像加速器
- **OpenClaw Gateway** — daemon 化，loopback 监听，配好 workspace
- **OpenCode Go（或其他 Provider）** — API key 注入，多模型 fallback 链
- **微信 ClawBot** — 扫码登录，DM pairing，群聊 requireMention
- **飞书 Bot** — WebSocket 长连接，无需公网 IP，配对审批
- **状态脚本 + 运维文档** — `openclaw-status` / `mihomo-status` / 日用 ops 指南

## 快速开始

1. 准备好一台全新安装的 Ubuntu 或 Debian 服务器，确保能 SSH 上去
2. 把本仓库 clone 下来（或直接复制 `SKILL.md` 内容）
3. 用 Claude Code 打开 `SKILL.md`
4. 填写"阶段 -1"中的参数（SSH 信息、Clash 订阅、API key 等）
5. 告诉 Claude Code：**"请按此 SKILL.md 帮我完成部署"**

Claude Code 会按 13 个阶段自动执行，每阶段验证后继续。

## 你需要准备的

- 服务器的 SSH 登录信息（IP、端口、用户、密码或 key）
- Clash 订阅链接（可选，海外服务器可跳过）
- LLM API Key（OpenCode Go / OpenAI / Anthropic / 自定义）
- 微信账号（可选，扫码登录）
- 飞书开发者账号（可选，参考 [`feishu-bot-guide.md`](feishu-bot-guide.md)）

## 安全原则

- 所有密钥 / 密码 / 订阅链接均为参数，不内置任何真实 secret
- Gateway 仅监听 127.0.0.1，不暴露公网
- mihomo 代理本机 only，allow-lan=false
- 私聊默认 pairing 审批，群聊默认 requireMention + allowlist
- Secret 文件权限 600，日志和报告自动脱敏

## 目录结构

```
├── SKILL.md                    # 主部署 Skill
├── feishu-bot-guide.md         # 飞书零基础接入教程
└── scripts/
    ├── mihomo-config-rewrite.sh    # mihomo 配置安全改写
    ├── openclaw-status.sh          # 状态检查脚本模板
    └── redact-secrets.sh           # 日志脱敏工具
```

## 适用范围

- 国内网络环境（USTC 镜像 + Clash 代理）
- 海外 VPS（可关闭代理，直连官方源）
- 个人日用、小团队共享、批量装机
