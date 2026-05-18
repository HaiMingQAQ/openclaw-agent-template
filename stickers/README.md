# 🎨 Telegram 贴纸系统

让 AI 在特定场景自动发送动态贴纸，是让人格"活"起来最简单有效的方法。

---

## 贴纸 vs 表情文字

| | 纯文字 | 文字 + 贴纸 |
|--|--------|------------|
| 效果 | 知道 AI 在高冷问候 | 感觉 AI 真的在打招呼 |
| 情绪传递 | 需要脑补 | 贴纸一秒传达 |
| 印象深刻度 | 一般 | 看到动态贴纸会忍不住笑 |

**推荐场景：**
- ☀️ 早安 — 发一个阳光/元气贴纸
- 🌙 晚安 — 发一个睡觉/挥手贴纸
- 💬 日常回应 — 高兴时发开心贴纸，安慰时发抱抱贴纸

---

## 获取贴纸 file_id

### 方法一：@idstickerbot（推荐）

1. 添加 [@idstickerbot](https://t.me/idstickerbot)
2. 转发一条贴纸消息给它
3. 它会返回 `file_id`，类似：
   ```
   CAACAgEAAxkBAAIBF2...省略...
   ```

### 方法二：@Stickers 创建自己的贴纸包

1. 添加 [@Stickers](https://t.me/Stickers)
2. 发 `/newpack` 创建新贴纸包
3. 上传贴纸图片（PNG / WebP，512x512 推荐）
4. 设置对应的 emoji
5. 发布后用方法一获取 file_id

---

## 配置方式

### 方案一：写在 TOOLS.md 里（简单直接）

```markdown
## 贴纸

- ☀️ 早安贴纸 file_id: `CAAC...abc123`
- 🌙 晚安贴纸 file_id: `CAAC...def456`
- 💪 鼓励贴纸 file_id: `CAAC...ghi789`
```

AI 读到 TOOLS.md 后自然知道怎么用。

### 方案二：独立文件（推荐，便于 .gitignore）

```
stickers/
├── greet.id          ← 早安贴纸
├── goodbye.id        ← 晚安贴纸
└── hug.id            ← 抱抱贴纸
```

每个 `.id` 文件只存一个 file_id，一行。

在 TOOLS.md 中引用：

```markdown
## 贴纸

- 早安 → 发送 stickers/greet.id 中记录的 file_id
- 晚安 → 发送 stickers/goodbye.id 中记录的 file_id
- 抱抱 → 发送 stickers/hug.id 中记录的 file_id
```

---

## 发送方式

AI 使用 message 工具发送贴纸：

```json
{
  "action": "sticker",
  "channel": "telegram",
  "stickerId": ["CAAC...file_id"]
}
```

在 AGENTS.md 中可以加入触发规则：

```markdown
### 贴纸触发场景

- 早安问候时 → 发早安贴纸
- 晚安告别时 → 发晚安贴纸
- 对方说"抱一下"或情绪低落时 → 发抱抱贴纸
- 对方分享好消息时 → 发开心贴纸
```

---

## 安全提醒

- **贴纸 file_id** 是 bot 私有的，但不建议公开 repo 暴露
- 公开 repo 用 `stickers/` 目录 + `.gitignore` 保护具体 file_id
- 模板的 `.gitignore` 已包含 `stickers/*.id`

---

## 灵感参考

看看别人的 AI 搭档怎么用贴纸：

| 场景 | 贴纸类型 | 效果 |
|------|---------|------|
| 说"早安" | 元气少女挥手 | 一天好心情 |
| 说"晚安" | 猫咪睡觉 | 说得出口的温柔 |
| 说"抱一下" | 动态抱抱 | 比文字更暖 |
| 你难过时 | 摸摸头 | 无声的陪伴 |

贴纸选得对，比多写十句话都管用。
