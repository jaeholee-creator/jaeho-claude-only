#!/bin/bash
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${GREEN}[Setup]${NC} $*"; }
error() { echo -e "${RED}[Error]${NC} $*" >&2; exit 1; }
warn() { echo -e "${YELLOW}[Warning]${NC} $*"; }

echo -e "${CYAN}"
echo "================================================"
echo "  Jaeho's Claude Code Environment Setup v2.0"
echo "  자동 오케스트레이션 & 자율 실행 모드"
echo "================================================"
echo -e "${NC}"

# Check Claude Code
if ! command -v claude &> /dev/null; then
    error "Claude Code CLI not found. Install from https://code.claude.com"
fi
log "Claude Code found: $(claude --version)"

# Check Node.js
if ! command -v node &> /dev/null; then
    error "Node.js not found. Install from https://nodejs.org"
fi
log "Node.js found: $(node --version)"

# Check Python
if ! command -v python3 &> /dev/null; then
    error "Python3 not found."
fi
log "Python3 found: $(python3 --version)"

# Load environment variables
if [ -f ".env" ]; then
    log "Loading environment variables from .env"
    export $(grep -v '^#' .env | xargs)
else
    warn ".env not found. Create from .env.example and add your tokens"
    if [ ! -f ".env.example" ]; then
        error ".env.example not found!"
    fi
    log "Run: cp .env.example .env"
    log "Then edit .env and add your tokens"
    exit 1
fi

# Backup existing config
BACKUP_DIR=~/.claude/.backup/$(date +%Y%m%d_%H%M%S)
if [ -d ~/.claude/agents ] || [ -d ~/.claude/skills ] || [ -f ~/.claude/CLAUDE.md ]; then
    log "Backing up existing configuration to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    [ -d ~/.claude/agents ] && cp -r ~/.claude/agents "$BACKUP_DIR/"
    [ -d ~/.claude/skills ] && cp -r ~/.claude/skills "$BACKUP_DIR/"
    [ -f ~/.claude/CLAUDE.md ] && cp ~/.claude/CLAUDE.md "$BACKUP_DIR/"
fi

# Create directories
log "Creating directories..."
mkdir -p ~/.claude/{agents,skills}
mkdir -p ~/.config/claude-mcp/notion-epic-tracker

# Copy agents
log "Installing agents..."
cp -r config/agents/* ~/.claude/agents/
AGENT_COUNT=$(ls -1 ~/.claude/agents/*.md 2>/dev/null | wc -l)
log "Installed $AGENT_COUNT agents"

# Copy skills
log "Installing skills..."
cp -r config/skills/* ~/.claude/skills/
SKILL_COUNT=$(find ~/.claude/skills -name "SKILL.md" 2>/dev/null | wc -l)
log "Installed $SKILL_COUNT skills"

# Copy CLAUDE.md
log "Installing CLAUDE.md..."
cp config/CLAUDE.md ~/.claude/CLAUDE.md

# Update settings.json
log "Updating settings..."
if [ -f ~/.claude/settings.json ]; then
    # Backup
    cp ~/.claude/settings.json ~/.claude/settings.json.bak
fi
cp config/settings.json ~/.claude/settings.json

# Update MCP configuration
log "Configuring MCP servers..."
if [ -f ~/.mcp.json ]; then
    cp ~/.mcp.json ~/.mcp.json.bak
    log "Backed up existing ~/.mcp.json"
fi

# Expand environment variables in mcp.json
export HOME="$HOME"
envsubst < config/mcp.json > ~/.mcp.json
log "MCP configuration updated"

# Install Python MCP server
log "Installing notion-epic-tracker..."
cp mcp-servers/notion-epic-tracker/* ~/.config/claude-mcp/notion-epic-tracker/

cd ~/.config/claude-mcp/notion-epic-tracker
if [ ! -d ".venv" ]; then
    log "Creating Python virtual environment..."
    python3 -m venv .venv
    log "Installing dependencies..."
    .venv/bin/pip install -q -r requirements.txt
else
    log "Virtual environment already exists, skipping..."
fi
cd - > /dev/null

# Check Mermaid CLI
log "Checking Mermaid CLI..."
if ! command -v mmdc &> /dev/null; then
    warn "Mermaid CLI not found. Install with: npm install -g @mermaid-js/mermaid-cli"
else
    log "Mermaid CLI found: $(mmdc --version | head -n1)"
fi

# Install Claude Code wrapper with mode selector
log "Installing Claude Code wrapper..."
SHELL_RC=""
if [ -f ~/.zshrc ]; then
    SHELL_RC=~/.zshrc
elif [ -f ~/.bashrc ]; then
    SHELL_RC=~/.bashrc
fi

if [ -n "$SHELL_RC" ]; then
    # Remove old wrapper if exists
    if grep -q "# Claude Code with mode selector" "$SHELL_RC"; then
        log "Removing old Claude Code wrapper..."
        sed -i.bak '/# Claude Code with mode selector/,/^}$/d' "$SHELL_RC"
    fi

    # Append new wrapper
    log "Adding Claude Code wrapper to $SHELL_RC"
    echo "" >> "$SHELL_RC"
    cat config/claude-wrapper.zsh >> "$SHELL_RC"
    log "Claude Code wrapper installed! Reload shell or run: source $SHELL_RC"
else
    warn "Shell RC file not found. Manually add config/claude-wrapper.zsh to your shell config"
fi

echo ""
echo -e "${GREEN}"
echo "================================================"
echo "  Setup Complete!"
echo "================================================"
echo -e "${NC}"
echo ""
echo "Installed components:"
echo "  ✓ $AGENT_COUNT custom agents (coordinator 포함)"
echo "  ✓ $SKILL_COUNT custom skills (워크플로우 6개 포함)"
echo "  ✓ CLAUDE.md global configuration (오케스트레이션 가이드)"
echo "  ✓ 6 MCP servers"
echo "  ✓ notion-epic-tracker Python server"
echo "  ✓ 자율 실행 모드 활성화"
echo "  ✓ Claude Code 모드 선택 wrapper (5가지 모드)"
echo ""
echo "Configuration location:"
echo "  ~/.claude/agents/"
echo "  ~/.claude/skills/"
echo "  ~/.claude/CLAUDE.md"
echo "  ~/.mcp.json"
echo ""
echo "Next steps:"
echo "  1. Reload your shell: source $SHELL_RC (또는 새 터미널 열기)"
echo "  2. Run 'claude' to see mode selector (5가지 모드 선택 가능)"
echo "  3. Use '@coordinator {요청}' for all tasks (권장!)"
echo "  4. Or use specific agents: '@oracle', '@code-reviewer', etc."
echo "  5. Try workflow skills: '/tdd-cycle', '/brainstorm-session', etc."
echo "  6. Use '/mcp' if needed to authenticate MCP servers"
echo ""
echo -e "${CYAN}🆕 자동 오케스트레이션:${NC}"
echo "  @coordinator가 작업을 분석하여 최적의 에이전트/스킬을 자동 선택합니다."
echo "  단순 작업은 즉시 처리, 복잡한 작업은 다중 에이전트 오케스트레이션!"
echo ""
echo -e "${CYAN}⚡ 자율 실행 모드:${NC}"
echo "  승인 요청 없이 작업 완료까지 자동 진행, 에러 발생 시 자동 재시도"
echo ""
echo -e "${CYAN}🎛️  모드 선택 기능:${NC}"
echo "  claude 명령어 실행 시 5가지 모드 중 선택 가능"
echo "  1. Default - 모든 작업 확인 요청"
echo "  2. Accept Edits - 파일 편집 자동 승인 (추천) ⭐"
echo "  3. Plan Mode - 읽기 전용 분석"
echo "  4. Don't Ask - 사전 승인 목록만 사용"
echo "  5. Bypass Permissions - 모든 권한 무시 (격리 환경만)"
echo ""
if ! command -v mmdc &> /dev/null; then
    echo -e "${YELLOW}Note: Install Mermaid CLI for diagram generation:${NC}"
    echo "  npm install -g @mermaid-js/mermaid-cli"
    echo ""
fi
