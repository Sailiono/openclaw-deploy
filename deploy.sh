#!/usr/bin/env bash
# OpenClaw Deploy — Usage Helper
# Detects available AI tools and guides you through using SKILL.md.
# Supports: Claude Code CLI, Claude Desktop, VS Code Copilot, Cursor, Codex, Windsurf
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_FILE="$SCRIPT_DIR/SKILL.md"
RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' CYAN='\033[0;36m' NC='\033[0m' BOLD='\033[1m'

banner() {
  echo -e "${CYAN}"
  echo "  ╔══════════════════════════════════════════════╗"
  echo "  ║         OpenClaw One-Click Deploy           ║"
  echo "  ║   Ubuntu / Debian → OpenClaw + Bots         ║"
  echo "  ╚══════════════════════════════════════════════╝"
  echo -e "${NC}"
}

check_file() {
  if [[ ! -f "$SKILL_FILE" ]]; then
    echo -e "${RED}[ERROR] SKILL.md not found at: $SKILL_FILE${NC}"
    echo "Make sure you're running this script from the openclaw-deploy directory."
    exit 1
  fi
}

detect_tools() {
  echo -e "${BOLD}Detecting AI coding tools...${NC}"
  echo ""

  TOOLS_FOUND=()

  # Claude Code CLI
  if command -v claude &>/dev/null; then
    TOOLS_FOUND+=("claude-cli")
    echo -e "  ${GREEN}✔${NC} Claude Code CLI   ${CYAN}(claude)${NC}"
  else
    echo -e "  ${RED}✗${NC} Claude Code CLI   (not found — npm install -g @anthropic-ai/claude-code)"
  fi

  # Claude Desktop (check for config file)
  if [[ -f "$HOME/.claude/claude_desktop_config.json" ]] || \
     [[ -f "$HOME/Library/Application Support/Claude/claude_desktop_config.json" ]] || \
     [[ -d "$APPDATA/Claude" ]] 2>/dev/null; then
    TOOLS_FOUND+=("claude-desktop")
    echo -e "  ${GREEN}✔${NC} Claude Desktop      ${CYAN}(config found)${NC}"
  else
    echo -e "  ${YELLOW}?${NC} Claude Desktop      (check if installed)"
  fi

  # VS Code / Cursor
  if command -v code &>/dev/null; then
    TOOLS_FOUND+=("vscode")
    echo -e "  ${GREEN}✔${NC} VS Code             ${CYAN}(code)${NC}"
  elif command -v cursor &>/dev/null; then
    TOOLS_FOUND+=("cursor")
    echo -e "  ${GREEN}✔${NC} Cursor              ${CYAN}(cursor)${NC}"
  else
    echo -e "  ${YELLOW}?${NC} VS Code / Cursor   (check if installed)"
  fi

  # GitHub Copilot
  if command -v gh && gh extension list 2>/dev/null | grep -q "copilot"; then
    TOOLS_FOUND+=("copilot-cli")
    echo -e "  ${GREEN}✔${NC} GitHub Copilot CLI  ${CYAN}(gh copilot)${NC}"
  else
    echo -e "  ${YELLOW}?${NC} GitHub Copilot     (check VS Code / CLI)"
  fi

  # Codex (OpenAI)
  if command -v codex &>/dev/null; then
    TOOLS_FOUND+=("codex")
    echo -e "  ${GREEN}✔${NC} OpenAI Codex CLI    ${CYAN}(codex)${NC}"
  else
    echo -e "  ${YELLOW}?${NC} OpenAI Codex       (not found)"
  fi

  # Windsurf
  if command -v windsurf &>/dev/null; then
    TOOLS_FOUND+=("windsurf")
    echo -e "  ${GREEN}✔${NC} Windsurf            ${CYAN}(windsurf)${NC}"
  else
    echo -e "  ${YELLOW}?${NC} Windsurf           (check if installed)"
  fi

  echo ""
  TOOLS_COUNT=${#TOOLS_FOUND[@]}
}

show_instructions() {
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}  How to use SKILL.md with your AI tool${NC}"
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""

  if [[ " ${TOOLS_FOUND[*]} " =~ "claude-cli" ]]; then
    echo -e "${GREEN}▶ Claude Code CLI (recommended)${NC}"
    echo "  cd $(pwd)"
    echo "  claude"
    echo "  Then in the Claude Code session, type:"
    echo "  @SKILL.md 请按此帮我完成部署"
    echo ""
  fi

  if [[ " ${TOOLS_FOUND[*]} " =~ "claude-desktop" ]]; then
    echo -e "${GREEN}▶ Claude Desktop${NC}"
    echo "  1. Open Claude Desktop"
    echo "  2. File → Open Project → select: $(pwd)"
    echo "  3. Claude auto-discovers SKILL.md as project knowledge"
    echo "  4. Type: 请按 SKILL.md 帮我完成部署"
    echo ""
  fi

  if [[ " ${TOOLS_FOUND[*]} " =~ "vscode" ]] || [[ " ${TOOLS_FOUND[*]} " =~ "cursor" ]]; then
    echo -e "${GREEN}▶ VS Code / Cursor${NC}"
    echo "  1. Open this folder: $(pwd)"
    echo "  2. In the AI chat panel, type: @SKILL.md 请按此帮我完成部署"
    echo "  (For Copilot Chat: use @workspace to reference SKILL.md)"
    echo ""
  fi

  if [[ " ${TOOLS_FOUND[*]} " =~ "copilot-cli" ]]; then
    echo -e "${GREEN}▶ GitHub Copilot CLI${NC}"
    echo "  cd $(pwd)"
    echo "  gh copilot suggest \"请按 SKILL.md 帮我完成部署\""
    echo ""
  fi

  if [[ " ${TOOLS_FOUND[*]} " =~ "codex" ]]; then
    echo -e "${GREEN}▶ OpenAI Codex CLI${NC}"
    echo "  cd $(pwd)"
    echo "  codex exec \"Read SKILL.md and follow it to deploy OpenClaw\""
    echo ""
  fi

  # Universal fallback
  echo -e "${YELLOW}▶ Universal (any AI tool)${NC}"
  echo "  1. Open SKILL.md in your editor"
  echo "  2. Copy the entire file content"
  echo "  3. Fill in the deployment parameters (section -1)"
  echo "  4. Paste everything into your AI chat"
  echo "  5. Say: 请按此 SKILL.md 帮我完成部署"
  echo ""
}

quick_start() {
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}  Quick Start${NC}"
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""

  # If Claude Code is available, offer direct launch
  if [[ " ${TOOLS_FOUND[*]} " =~ "claude-cli" ]]; then
    echo -e "Launch Claude Code with SKILL.md pre-loaded?"
    echo -e "  ${CYAN}claude --project $(pwd)${NC}"
    echo ""
    read -rp "  Start now? [y/N] " REPLY
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
      echo ""
      cd "$(pwd)" && exec claude --project "$(pwd)"
    fi
  fi
}

# ── Main ──────────────────────────────────────────────────────────
banner
check_file
detect_tools
show_instructions
quick_start
