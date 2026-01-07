#!/bin/bash

# Claude Skills Installer

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Installing Claude Bootstrap..."
echo ""

# Create directories
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/skills"
mkdir -p "$CLAUDE_DIR/hooks"
mkdir -p "$CLAUDE_DIR/plugins"

# Copy all commands
cp "$SCRIPT_DIR/commands/"*.md "$CLAUDE_DIR/commands/"
echo "✓ Installed commands:"
ls -1 "$CLAUDE_DIR/commands/" | sed 's/^/  - \//' | sed 's/\.md$//'

# Copy skills
cp "$SCRIPT_DIR/skills/"*.md "$CLAUDE_DIR/skills/"
echo "✓ Installed $(ls -1 "$CLAUDE_DIR/skills/"*.md | wc -l | tr -d ' ') skills"

# Copy hooks
cp "$SCRIPT_DIR/hooks/"* "$CLAUDE_DIR/hooks/" 2>/dev/null || true
chmod +x "$CLAUDE_DIR/hooks/"* 2>/dev/null || true
echo "✓ Installed git hooks (templates)"

# Copy hook installer script
cp "$SCRIPT_DIR/scripts/install-hooks.sh" "$CLAUDE_DIR/" 2>/dev/null || true
chmod +x "$CLAUDE_DIR/install-hooks.sh" 2>/dev/null || true

# Check for Ralph Loop plugin
echo ""
if [ -d "$CLAUDE_DIR/plugins/marketplaces/claude-plugins-official/plugins/ralph-loop" ]; then
    echo "✓ Ralph Loop plugin available in marketplace"
    echo "  To install: /install-plugin ralph-loop (in Claude Code)"
else
    echo "⚠ Ralph Loop plugin not found in marketplace"
    echo "  Update marketplace: /update-marketplace (in Claude Code)"
    echo "  Then install: /install-plugin ralph-loop"
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Installation complete!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Usage:"
echo "  1. Open any project folder"
echo "  2. Run: claude"
echo "  3. Type: /initialize-project"
echo ""
echo "Commands installed:"
echo "  /initialize-project   - Full project setup"
echo "  /check-contributors   - Team coordination"
echo "  /update-code-index    - Regenerate code index"
echo ""
echo "Git Hooks (per-project):"
echo "  cd your-project && ~/.claude/install-hooks.sh"
echo ""
