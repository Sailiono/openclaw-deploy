# OpenClaw Deploy — Usage Helper (PowerShell)
# Detects available AI tools and guides you through using SKILL.md.
# Supports: Claude Code CLI, Claude Desktop, VS Code Copilot, Cursor, Codex

param([switch]$Launch)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillFile = Join-Path $ScriptDir "SKILL.md"

function Write-Banner {
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║         OpenClaw One-Click Deploy           ║" -ForegroundColor Cyan
    Write-Host "  ║   Ubuntu / Debian → OpenClaw + Bots         ║" -ForegroundColor Cyan
    Write-Host "  ╚══════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

if (-not (Test-Path $SkillFile)) {
    Write-Host "[ERROR] SKILL.md not found at: $SkillFile" -ForegroundColor Red
    exit 1
}

Write-Banner

Write-Host "Detecting AI coding tools..." -ForegroundColor White
Write-Host ""

# Claude Code CLI
$claudeCli = Get-Command claude -ErrorAction SilentlyContinue
if ($claudeCli) {
    Write-Host "  [✓] Claude Code CLI       (claude)" -ForegroundColor Green
} else {
    Write-Host "  [✗] Claude Code CLI       (npm install -g @anthropic-ai/claude-code)" -ForegroundColor Red
}

# Claude Desktop
$claudeDesktop = Get-Command "Claude" -ErrorAction SilentlyContinue
if ($claudeDesktop -or (Test-Path "$env:LOCALAPPDATA\AnthropicClaude")) {
    Write-Host "  [✓] Claude Desktop        (installed)" -ForegroundColor Green
} else {
    Write-Host "  [?] Claude Desktop        (check if installed)" -ForegroundColor Yellow
}

# VS Code
$vscode = Get-Command code -ErrorAction SilentlyContinue
if ($vscode) {
    Write-Host "  [✓] VS Code               (code)" -ForegroundColor Green
} else {
    Write-Host "  [?] VS Code               (check if installed)" -ForegroundColor Yellow
}

# Cursor
$cursor = Get-Command cursor -ErrorAction SilentlyContinue
if ($cursor) {
    Write-Host "  [✓] Cursor                (cursor)" -ForegroundColor Green
} else {
    Write-Host "  [?] Cursor                (check if installed)" -ForegroundColor Yellow
}

# Windsurf
$windsurf = Get-Command windsurf -ErrorAction SilentlyContinue
if ($windsurf) {
    Write-Host "  [✓] Windsurf              (windsurf)" -ForegroundColor Green
} else {
    Write-Host "  [?] Windsurf              (check if installed)" -ForegroundColor Yellow
}

# GitHub Copilot (VS Code extension)
Write-Host "  [?] GitHub Copilot        (check VS Code extensions)" -ForegroundColor Yellow

Write-Host ""

# ── Instructions ──────────────────────────────────────────────────
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor White
Write-Host "  How to use SKILL.md with your AI tool" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor White
Write-Host ""

Write-Host "▶ Claude Code CLI (recommended)" -ForegroundColor Green
Write-Host "  claude"
Write-Host "  Then type: @SKILL.md 请按此帮我完成部署"
Write-Host ""

Write-Host "▶ Claude Desktop" -ForegroundColor Green
Write-Host "  1. Open Claude Desktop"
Write-Host "  2. File → Open Project → select this folder"
Write-Host "  3. Type: 请按 SKILL.md 帮我完成部署"
Write-Host ""

Write-Host "▶ VS Code / Cursor / Windsurf" -ForegroundColor Green
Write-Host "  1. Open this folder"
Write-Host "  2. In AI chat: @SKILL.md 请按此帮我完成部署"
Write-Host ""

Write-Host "▶ Universal (any AI tool)" -ForegroundColor Yellow
Write-Host "  1. Open SKILL.md, copy all content"
Write-Host "  2. Fill in deployment parameters (section -1)"
Write-Host "  3. Paste into your AI chat and say: 请按此帮我完成部署"
Write-Host ""

# Quick launch
if ($Launch -or $claudeCli) {
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor White
    Write-Host "  Quick Launch" -ForegroundColor White
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor White
    Write-Host ""
    Write-Host "Launch Claude Code now? [y/N] " -ForegroundColor Cyan -NoNewline
    $reply = Read-Host
    if ($reply -eq 'y' -or $reply -eq 'Y') {
        Set-Location $ScriptDir
        claude --project $ScriptDir
    }
}
