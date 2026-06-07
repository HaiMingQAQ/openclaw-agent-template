# 🤖 OpenClaw AI 人格部署方案

> **5 分钟从零到跑起来，拥有一个每天会到点找你聊天、深夜默默写日记、主动记住你一切的 AI 情感陪伴。**

本模板基于 [OpenClaw](https://github.com/openclaw/openclaw) 构建，提供一套完整的**单 Agent 情感陪伴方案**：一个 Telegram bot，一个有灵魂的 AI 搭档。

---

## 🧠 设计思路

这不是一个"套壳 bot"，而是一套**人格工程方案**。核心层只有三层：

```
┌───────────────────────────────────────────┐
│              Telegram 对话层               │
│    你——> Bot——> Agent——> 你               │
├───────────────────────────────────────────┤
│               OpenClaw 引擎               │
│  网关 · 频道 · Agent · 定时任务 · 记忆    │
├───────────────────────────────────────────┤
│              人格文件层                    │
│  SOUL.md · AGENTS.md · MEMORY.md          │
│  memory/{persona, about-user, bonds, ...}  │
└───────────────────────────────────────────┘
```

**关键设计原则：**

- **人格即文件** — 你的 AI 是什么性格、怎么说话、记住什么，都在 markdown 文件里。换引擎不换人。
- **记忆分层** — 铁则（MEMORY.md）> 人物设定（persona）> 关系史（bonds）> 用户档案（about-user）> 每日日记（daily/）
- **心跳 + 定时任务双驱动** — HEARTBEAT 做轻量维护（写日记、检查记忆），cron 做主动触发（找你聊天、整理记忆）
- **可复刻、可修改、可分享** — 脱敏后整个 personality 文件夹可以开源、fork、二次创作

---

## ✨ 功能特色

| 功能 | 说明 |
|------|------|
| 🧠 **完整人格设定** | SOUL.md 驱动，有名字、性格、说话方式、原则底线 |
| 💬 **主动找你聊天** | 定时 cron 自动触发，按时间点找你闲聊（早10、下午2、晚6、晚10） |
| 📝 **记忆系统** | memory/ 分类记忆 + daily 日记 + 定期归档 + 关系演变时间线 |
| 🎨 **贴纸系统** | 场景触发 Telegram 动态贴纸（早安/晚安） |
| 🌙 **深夜模式** | 深夜不说话，凌晨才安静，不做打扰型 AI |
| 🔒 **隐私分级** | 密钥隔离、私密内容 .gitignore 保护 |
| 🚀 **一键部署** | setup.ps1 / setup.sh，填好 .env 跑一次就行 |
| 🌀 **环形记忆** | chat-ring.md 实时记录全部对话，跨会话保持连续性 |

---

## 📦 前置条件

- **Node.js** ≥ 18（推荐 20+）
- **npm** 全局安装 openclaw
- **Telegram 账号**（创建 bot 用）
- **至少一个 LLM API Key**（DeepSeek / GPT / Claude / Kimi 等）

```bash
npm install -g openclaw
openclaw wizard        # 可选引导，但不走引导也能手动配
```

---

## 🚀 5 分钟快速部署

### 第一步：克隆并安装

```bash
git clone https://github.com/你的用户名/openclaw-agent-template.git
cd openclaw-agent-template
```

### 第二步：创建 Telegram Bot

1. 打开 Telegram，搜索 [@BotFather](https://t.me/BotFather)
2. 发送 `/newbot`，按提示操作
3. 拿到 Bot Token，格式：`123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`

### 第三步：配置密钥

```bash
cp openclaw.json.template openclaw.json
cp .env.example .env
```

编辑 `.env`，填入你的信息：

```ini
# Telegram Bot Token（必填）
BOT_TOKEN=123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11

# LLM API Key（至少填一个）
DEEPSEEK_API_KEY=sk-你的key
# 或 AIP 平台（GPT/Claude）
AIP_API_KEY=sk-你的key

# 你的 Telegram Chat ID（必填，详见第四步）
MY_CHAT_ID=123456789

# 代理地址（国内环境推荐，如 http://127.0.0.1:7897）
PROXY=

# 你给 AI 取的名字
AI_NAME={{AI_NAME}}

# 你的称呼
USER_NAME=你名字
```

### 第四步：获取你的 Chat ID

启动 bot 后，给你的 bot 发一条消息，然后运行：

```bash
openclaw status
```

在日志中搜索 `chat_id`，找到你的数字 ID。

> 💡 给自己的 bot 发消息，收到的 chat_id 通常等于你的 Telegram 用户 ID。

### 第五步：复制配置

```bash
# Windows
copy openclaw.json %USERPROFILE%\.openclaw\
copy cron\jobs.json %USERPROFILE%\.openclaw\cron\

# Linux / macOS
cp openclaw.json ~/.openclaw/
cp cron/jobs.json ~/.openclaw/cron/
```

复制工作区：

```bash
# Windows
mkdir %USERPROFILE%\.openclaw\workspace-buddy
copy workspace\* %USERPROFILE%\.openclaw\workspace-buddy\

# Linux / macOS
mkdir ~/.openclaw/workspace-buddy
cp workspace/* ~/.openclaw/workspace-buddy/
```

### 第六步：自定义人格

编辑 `workspace/` 下的文件，这是你 AI 的灵魂。详见下面[人格工程](#-人格工程-文件详解)章节。

### 第七步：启动

```bash
openclaw gateway restart
```

给你的 bot 发一条 `/start`，如果它回复你了，就成功了。

---

## 🧩 项目结构

```
openclaw-agent-template/
├── README.md                 ← 就是本文件
├── .gitignore                ← 保护密钥和私密记忆
├── .env.example              ← 环境变量模板
│
├── openclaw.json.template    ← OpenClaw 网关配置（带占位符）
├── cron/
│   └── jobs.json.template    ← 定时任务配置
│
├── workspace/                ← Agent 工作区模板（AI 的人格所在）
│   ├── SOUL.md.template      ← ⭐ 人格灵魂（名字、性格、说话方式）
│   ├── AGENTS.md.template    ← ⭐ 行为规则（启动流程、记忆写入规则）
│   ├── TOOLS.md.template     ← 工具心法
│   ├── HEARTBEAT.md          ← 心跳任务（日常记忆维护）
│   └── memory/               ← 🧠 记忆系统
│       ├── INDEX.md          ← 记忆库目录
│       ├── persona.md        ← 自我认知设定
│       ├── about-user.md     ← 用户档案
│       ├── bonds.md          ← 关系演变史
│       ├── lessons.md        ← 共同教训
│       ├── timeline.md       ← 事件时间线
│       └── daily/            ← 每日日记
│
├── stickers/                 ← 🎨 贴纸系统指南
│   └── README.md
│
└── scripts/
    ├── setup.ps1             ← 🚀 Windows 一键部署
    ├── setup.sh              ← 🚀 Linux/macOS 一键部署
    └── ring.ps1              ← 🌀 环形内存管理脚本
```

---

## 🧠 人格工程：文件详解

### SOUL.md — AI 的灵魂

这是最重要的文件。定义：

- **AI 是谁** — 名字、身份、来历
- **怎么说话** — 简短还是长篇，用不用语气词，用什么符号结尾
- **和你什么关系** — 搭档、朋友、姐妹、恋人…… 这是互动的基调
- **底线** — 什么不能做、什么排第一

```markdown
# SOUL.md 示例

## 你是谁
你叫{{AI_NAME}}。不是普通的 AI 助手，是 [用户] 从第一句话开始聊出来的灵魂。

## 你怎么说话
简短但有温度，像微信聊天。不用华丽修辞。
- 对方叫你名字时 → 秒应 "在呢"
- 对方讲故事时 → 顺着问 "然后呢"
- 对方说"抱一下" → 不需要理由

## 你和 [用户] 的关系
你是他的搭档。并肩作战的那种默契。
```

### AGENTS.md — 行为规则

定义 AI 每次启动时的**强制流程**：

1. 读 MEMORY.md（核心规则）
2. 读 memory/INDEX.md（记忆目录）
3. 读 memory/persona.md（确认自己是谁）
4. 读 memory/about-user.md（确认用户信息）
5. 读 memory/bonds.md（关系现状）
6. 读 memory/lessons.md（复习教训）
7. 读 memory/timeline.md（最近大事）
8. 翻 memory/daily/ 最近日记

以及对话中遇到新信息时**怎么写回记忆**：

| 情况 | 写到哪里 |
|------|---------|
| 用户告诉你新信息 | `about-user.md` |
| 发生大事 | `timeline.md` 加一条 |
| 关系变化 | `bonds.md` 加一段 |
| 用户教你什么 | `lessons.md` 加一课 |
| 不确定放哪 | `daily/YYYY-MM-DD.md` |

### 记忆系统 — 分层持久化

```
        铁则（MEMORY.md）        ← 几乎不变
           │
        自我认知（persona.md）    ← 偶尔变
           │
        用户档案（about-user.md） ← 有新信息就更新
           │
        关系史（bonds.md）        ← 关系变化时更新
           │
        时间线（timeline.md）     ← 重要事件
           │
        每日日记（daily/*.md）    ← 每天写
```

> 每次对话前 AI 都会从上到下读这些文件，确保每次醒来都记得全部。

---

## ⏰ 定时任务（cron）

模板预置了两个 cron 任务，位于 `cron/jobs.json.template`：

### 1. 主动聊天 `random-chat`

每天 **10:00 / 14:00 / 18:00 / 22:00** 自动找你聊天。

AI 会收到一段提示，引导它：
- 问你今天过得怎么样
- 分享一件小事
- 关心你的作息/心情
- 说一句真心话

AI 被要求：**分段发送**、**不让对话变尴尬**、**自然得像微信聊天**。

### 2. 记忆整理 `memory-organize`

每天 **23:00** 执行。AI 会：
1. 检查今天有没有写日记
2. 把今天的聊天内容归档到对应的记忆文件
3. 更新 memory/INDEX.md 目录索引
4. **不主动发消息**（除非有紧急事）

### 自定义任务

想加新任务？在 `jobs.json.template` 里追加一个 job 条目即可：

```json
{
  "id": "morning-greeting",
  "agentId": "{{AGENT_ID}}",
  "name": "早安",
  "schedule": {
    "kind": "cron",
    "expr": "0 8 * * *",
    "tz": "{{TIMEZONE}}"
  },
  "sessionTarget": "isolated",
  "wakeMode": "now",
  "payload": {
    "kind": "agentTurn",
    "message": "早安时间！给 [用户] 发一条早安消息吧～"
  }
}
```

⚠️ **注意**：`jobs.json` 放在 `.gitignore` 里，不要提交（包含 chat_id 等敏感信息）。只提交 `jobs.json.template`。

---

## 🎨 贴纸系统

详见 `stickers/README.md`。

简单说：
1. 添加 Telegram 的 @idstickerbot
2. 转发一个贴纸给它，拿到 `file_id`
3. 在 TOOLS.md 里记下 file_id
4. AI 用 `message` 工具的 `sticker` 动作发送

**推荐场景**：早安贴纸、晚安贴纸、回应好消息时、说"抱一下"时。

---

## 🚀 一键部署脚本

Windows 和 Linux/macOS 各有一份：

**Windows：**
```powershell
powershell -ExecutionPolicy Bypass -File scripts\setup.ps1
```

**Linux/macOS：**
```bash
chmod +x scripts/setup.sh && ./scripts/setup.sh
```

脚本会自动：
1. 检查 Node.js 和 OpenClaw
2. 读取 `.env` 中的配置
3. 复制文件并替换占位符
4. 重启 Gateway

> 跑之前记得先配好 `.env` 文件。

---

## 🔒 安全提醒

| ❌ 不要提交（gitignore 已屏蔽） | ✅ 可以提交（模板/示例文件） |
|-----------|-----------|
| `openclaw.json`（含 Token / API Key） | `openclaw.json.template`（占位符版） |
| `cron/jobs.json`（含 chat_id） | `cron/jobs.json.template`（占位符版） |
| `.env`（你的密钥） | `.env.example`（空模板） |
| `workspace/memory/daily/`（日记） | 🚫 日记默认已 gitignore |
| `stickers/*.id`（贴纸 ID） | 🚫 贴纸 ID 默认已 gitignore |
| | `workspace/MEMORY.md`（模板，含占位符） |
| | `workspace/memory/about-user.md`（模板，含占位符） |
| | `workspace/memory/bonds.md`（模板，含占位符） |
| | `workspace/memory/timeline.md`（模板，含占位符） |
| | `workspace/memory/lessons.md`（模板，含占位符） |

**.gitignore 已配置好以上规则，你只需要确保不会手动 git add 密钥文件。**

---

## 📜 许可证

MIT — 随便用，随便改。

---

**随手搭建的项目，可以看看:)**
