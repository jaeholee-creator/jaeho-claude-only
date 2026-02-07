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
echo "  Jaeho's Claude Code Environment Setup"
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

echo ""
echo -e "${GREEN}"
echo "================================================"
echo "  Setup Complete!"
echo "================================================"
echo -e "${NC}"
echo ""
echo "Installed components:"
echo "  ✓ $AGENT_COUNT custom agents"
echo "  ✓ $SKILL_COUNT custom skills"
echo "  ✓ CLAUDE.md global configuration"
echo "  ✓ 6 MCP servers"
echo "  ✓ notion-epic-tracker Python server"
echo ""
echo "Configuration location:"
echo "  ~/.claude/agents/"
echo "  ~/.claude/skills/"
echo "  ~/.claude/CLAUDE.md"
echo "  ~/.mcp.json"
echo ""
echo "Next steps:"
echo "  1. Run 'claude' to start a session"
echo "  2. Use '/agents' to see available agents"
echo "  3. Use '@agent-name' to invoke specific agents"
echo "  4. Use '/mcp' if needed to authenticate MCP servers"
echo ""
if ! command -v mmdc &> /dev/null; then
    echo -e "${YELLOW}Note: Install Mermaid CLI for diagram generation:${NC}"
    echo "  npm install -g @mermaid-js/mermaid-cli"
    echo ""
fi
