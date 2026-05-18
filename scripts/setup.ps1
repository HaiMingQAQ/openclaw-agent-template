<#
.SYNOPSIS
  OpenClaw AI 人格部署脚本 (Windows)
.DESCRIPTION
  从模板一键部署 AI Agent 到 OpenClaw。
  要求：Node.js >= 18、openclaw 已安装、.env 已配置。
#>

$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "OpenClaw 部署脚本"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenClaw AI 人格部署脚本 (Windows)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# --- 1. 检查 Node.js ---
try {
    $nodeVersion = node --version
    Write-Host "[✓] Node.js $nodeVersion"
} catch {
    Write-Host "[✗] 未安装 Node.js！请先安装：https://nodejs.org/" -ForegroundColor Red
    exit 1
}

# --- 2. 检查 OpenClaw ---
try {
    $ocVersion = openclaw --version 2>$null
    Write-Host "[✓] OpenClaw $ocVersion"
} catch {
    Write-Host "[!] 未安装 OpenClaw，正在安装..." -ForegroundColor Yellow
    npm install -g openclaw
    if ($LASTEXITCODE -ne 0) { exit 1 }
    Write-Host "[✓] 安装完成"
}

# --- 3. 定位项目目录 ---
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Split-Path -Parent $scriptDir
Write-Host "[*] 项目目录: $projectDir"

# --- 4. 检查 .env ---
if (-not (Test-Path "$projectDir\.env")) {
    Write-Host "[!] 未找到 .env！请复制 .env.example 为 .env 后重试" -ForegroundColor Yellow
    exit 1
}

# --- 5. 加载配置 ---
Write-Host "[*] 读取配置..."
$envVars = @{}
Get-Content "$projectDir\.env" | ForEach-Object {
    if ($_ -match '^([^#=]+)=["\']?(.+?)["\']?$') {
        $k = $matches[1].Trim()
        $v = $matches[2].Trim()
        if ($v -ne '') { $envVars[$k] = $v }
    }
}

# 检查必要配置
$missing = @("BOT_TOKEN", "MY_CHAT_ID") | Where-Object { -not $envVars.ContainsKey($_) }
if ($missing) {
    Write-Host "[✗] .env 缺少: $($missing -join ', ')" -ForegroundColor Red; exit 1
}

# --- 6. 确定路径 ---
$aiName = $envVars['AI_NAME'] ?? "buddy"
$agentId = $envVars['AGENT_ID'] ?? "buddy"
$wsName = "workspace-$agentId"
$ocDir = "$env:USERPROFILE\.openclaw"
$wsDir = "$ocDir\$wsName"
if (-not $envVars['WORKSPACE_PATH']) { $envVars['WORKSPACE_PATH'] = $wsDir }

# --- 7. 创建目录 ---
New-Item -ItemType Directory -Path "$ocDir\cron" -Force | Out-Null
New-Item -ItemType Directory -Path "$wsDir\memory\daily" -Force | Out-Null

# --- 8. 复制文件 ---
Write-Host "[*] 复制模板文件..."
@(
    "openclaw.json.template", "$ocDir\openclaw.json"
    "cron\jobs.json.template", "$ocDir\cron\jobs.json"
    "workspace\SOUL.md.template", "$wsDir\SOUL.md"
    "workspace\AGENTS.md.template", "$wsDir\AGENTS.md"
    "workspace\TOOLS.md.template", "$wsDir\TOOLS.md"
    "workspace\HEARTBEAT.md", "$wsDir\HEARTBEAT.md"
    "workspace\MEMORY.md", "$wsDir\MEMORY.md"
) | ForEach-Object { $i=0 } { if (++$i % 2) { $src = $_ } else {
    Copy-Item "$projectDir\$src" $_ -Force
}}

# 复制 memory 文件
Copy-Item "$projectDir\workspace\memory\*.md" "$wsDir\memory\" -Force

# 创建 chat-ring.md（环形内存初始文件）
$ringHeader = @"
# {{AI_NAME}} 的环形内存
> 最近10K条消息记录，新消息覆盖旧消息。
> 每次会话启动时读取此文件以获得连续上下文。
>
> 格式: [时间] 发送者 -> 接收者: 消息内容

---

"@
Set-Content "$wsDir\chat-ring.md" $ringHeader

# --- 9. 替换占位符 ---
Write-Host "[*] 替换占位符..."
$envVars['TIME'] = Get-Date -Format "HH:mm"
$envVars['DATE'] = Get-Date -Format "yyyy-MM-dd"

$files = @(
    "$ocDir\openclaw.json", "$ocDir\cron\jobs.json"
) + (Get-ChildItem "$wsDir" -Filter "*.md" -Recurse | % FullName)

foreach ($f in $files) {
    $c = Get-Content $f -Raw
    foreach ($k in $envVars.Keys) {
        $c = $c -replace "{{$k}}", $envVars[$k]
    }
    Set-Content $f $c
}

Write-Host "[✓] 配置写入完成！"
Write-Host "    AI: $aiName  |  工作区: $wsName"

# --- 10. 重启 Gateway ---
Write-Host "[*] 重启 Gateway..."
try {
    # 通过 Scheduled Task 启动（更可靠）
    Start-ScheduledTask -TaskName "OpenClaw Gateway" -ErrorAction SilentlyContinue
    Write-Host "[✓] Gateway 已重启"
} catch {
    try {
        Start-Process -NoNewWindow "openclaw" -ArgumentList "gateway run"
        Write-Host "[✓] Gateway 已直接启动"
    } catch {
        Write-Host "[!] 请手动重启: openclaw gateway restart" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "部署完成！下一步：" -ForegroundColor Cyan
Write-Host "  1. 给 bot 发 /start" -ForegroundColor Gray
Write-Host "  2. 等 cron 触发推送" -ForegroundColor Gray
Write-Host "  3. 编辑 $wsName 下的文件微调人格" -ForegroundColor Gray
Read-Host "`n按 Enter 退出"
