#!/bin/bash
# OpenClaw AI 人格部署脚本 (Linux/macOS)
# 用法: chmod +x scripts/setup.sh && ./scripts/setup.sh

set -e

echo "========================================"
echo "  OpenClaw AI 人格部署脚本 (Linux/macOS)"
echo "========================================"
echo ""

# --- 1. 检查 Node.js ---
if command -v node &>/dev/null; then
    echo "[✓] Node.js $(node --version)"
else
    echo "[✗] 未安装 Node.js！请先安装：https://nodejs.org/"
    exit 1
fi

# --- 2. 检查 OpenClaw ---
if command -v openclaw &>/dev/null; then
    echo "[✓] OpenClaw installed"
else
    echo "[!] 未安装 OpenClaw，正在安装..."
    npm install -g openclaw
    echo "[✓] 安装完成"
fi

# --- 3. 定位项目目录 ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
echo "[*] 项目目录: $PROJECT_DIR"

# --- 4. 检查 .env ---
if [ ! -f "$PROJECT_DIR/.env" ]; then
    echo "[!] 未找到 .env！请复制 .env.example 为 .env 后重试"
    exit 1
fi

# --- 5. 加载配置 ---
echo "[*] 读取配置..."
set -a
source "$PROJECT_DIR/.env"
set +a

# 检查必要配置
: "${BOT_TOKEN:?[✗] .env 缺少 BOT_TOKEN}"
: "${MY_CHAT_ID:?[✗] .env 缺少 MY_CHAT_ID}"

# --- 6. 确定路径 ---
AI_NAME="${AI_NAME:-buddy}"
AGENT_ID="${AGENT_ID:-buddy}"
WS_NAME="workspace-${AGENT_ID}"
OC_DIR="$HOME/.openclaw"
WS_DIR="${WORKSPACE_PATH:-$OC_DIR/$WS_NAME}"
export WORKSPACE_PATH="$WS_DIR"

# --- 7. 创建目录 ---
mkdir -p "$OC_DIR/cron"
mkdir -p "$WS_DIR/memory/daily"

# --- 8. 复制文件 ---
echo "[*] 复制模板文件..."
cp "$PROJECT_DIR/openclaw.json.template" "$OC_DIR/openclaw.json"
cp "$PROJECT_DIR/cron/jobs.json.template" "$OC_DIR/cron/jobs.json"
cp "$PROJECT_DIR/workspace/SOUL.md.template" "$WS_DIR/SOUL.md"
cp "$PROJECT_DIR/workspace/AGENTS.md.template" "$WS_DIR/AGENTS.md"
cp "$PROJECT_DIR/workspace/TOOLS.md.template" "$WS_DIR/TOOLS.md"
cp "$PROJECT_DIR/workspace/HEARTBEAT.md" "$WS_DIR/HEARTBEAT.md"
cp "$PROJECT_DIR/workspace/MEMORY.md" "$WS_DIR/MEMORY.md"
cp "$PROJECT_DIR/workspace/memory/"*.md "$WS_DIR/memory/"

# 创建 chat-ring.md（环形内存初始文件）
cat > "$WS_DIR/chat-ring.md" << 'EOF'
# {{AI_NAME}} 的环形内存
> 最近10K条消息记录，新消息覆盖旧消息。
> 每次会话启动时读取此文件以获得连续上下文。
>
> 格式: [时间] 发送者 -> 接收者: 消息内容

---

EOF

# --- 9. 替换占位符 ---
echo "[*] 替换占位符..."

# .env 中不需要替换的 key
SKIP_KEYS="BOT_TOKEN DEEPSEEK_API_KEY AIP_API_KEY SILICONFLOW_API_KEY"

# 替换 openclaw.json
while IFS='=' read -r key value; do
    [[ "$key" =~ ^#.*$ ]] && continue
    [ -z "$key" ] && continue
    value="${value#\"}"; value="${value%\"}"
    value="${value#\'}"; value="${value%\'}"
    sed -i "s|{{$key}}|$value|g" "$OC_DIR/openclaw.json" 2>/dev/null
done < "$PROJECT_DIR/.env"

# 替换 cron/jobs.json
sed_replace() {
    local file="$1"
    while IFS='=' read -r key value; do
        [[ "$key" =~ ^#.*$ ]] && continue
        [ -z "$key" ] && continue
        value="${value#\"}"; value="${value%\"}"
        value="${value#\'}"; value="${value%\'}"
        sed -i "s|{{$key}}|$value|g" "$file" 2>/dev/null
    done < "$PROJECT_DIR/.env"
}
sed_replace "$OC_DIR/cron/jobs.json"

# 替换 workspace 中所有 markdown 文件
find "$WS_DIR" -name "*.md" | while read f; do
    while IFS='=' read -r key value; do
        [[ "$key" =~ ^#.*$ ]] && continue
        [ -z "$key" ] && continue
        value="${value#\"}"; value="${value%\"}"
        value="${value#\'}"; value="${value%\'}"
        sed -i "s|{{$key}}|$value|g" "$f" 2>/dev/null
    done < "$PROJECT_DIR/.env"
done

echo "[✓] 配置写入完成！"
echo "    AI: $AI_NAME  |  工作区: $WS_NAME"

# --- 10. 重启 Gateway ---
echo "[*] 重启 Gateway..."
if openclaw gateway restart 2>/dev/null; then
    echo "[✓] Gateway 已重启"
else
    echo "[!] 请手动重启: openclaw gateway restart"
fi

echo ""
echo "部署完成！下一步："
echo "  1. 给 bot 发 /start"
echo "  2. 等 cron 触发推送"
echo "  3. 编辑 $WS_DIR 下的文件微调人格"
echo ""
