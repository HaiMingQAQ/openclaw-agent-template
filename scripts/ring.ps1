<#
.SYNOPSIS
  环形内存管理脚本
.DESCRIPTION
  将对话实时写入环形缓冲区文件，用于跨会话保持对话连续性。
  最大 10,000 条，超限时保留最近 5,000 条。

用法:
  .\ring.ps1 add "消息内容"    → 追加一条消息
  .\ring.ps1 stats             → 查看统计
  .\ring.ps1 trim              → 手动裁剪
#>

param(
    [string]$action = "",
    [string]$message = ""
)

$ringFile = "chat-ring.md"
$maxLines = 10000
$keepLines = 5000
$utf8 = New-Object System.Text.UTF8Encoding $false

function Add-Message {
    param([string]$msg)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] $msg"
    [System.IO.File]::AppendAllText((Get-Item $ringFile).FullName, $line + [Environment]::NewLine, $utf8)
    Write-Output "OK: $line"
}

function Trim-File {
    $lines = [System.IO.File]::ReadAllLines((Get-Item $ringFile).FullName, $utf8)
    $count = $lines.Length
    if ($count -gt $maxLines) {
        $trimmed = $lines[($count - $keepLines)..($count - 1)]
        [System.IO.File]::WriteAllLines((Get-Item $ringFile).FullName, $trimmed, $utf8)
        $removed = $count - $keepLines
        Write-Output "TRIM: removed $removed lines, kept $keepLines"
    } else {
        Write-Output "OK: $count lines, under limit"
    }
}

function Show-Stats {
    $lines = [System.IO.File]::ReadAllLines((Get-Item $ringFile).FullName, $utf8)
    $count = $lines.Length
    Write-Output "STATS: $count lines total (max $maxLines)"
}

switch ($action) {
    "add" {
        if ($message -ne "") {
            Add-Message $message
            Trim-File
        } else {
            Write-Output "ERROR: no message"
        }
    }
    "trim" {
        Trim-File
    }
    "stats" {
        Show-Stats
    }
    default {
        Write-Output "Usage: ring.ps1 add|trim|stats"
    }
}
