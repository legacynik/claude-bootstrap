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

# Install Ralph Wiggum plugin (iterative loops)
echo ""
echo "Checking Ralph Wiggum plugin..."
if [ -d "$CLAUDE_DIR/plugins/ralph-wiggum" ]; then
    echo "✓ Ralph Wiggum plugin already installed"
else
    echo "Installing Ralph Wiggum plugin (iterative TDD loops)..."
    if command -v git &> /dev/null; then
        TEMP_DIR=$(mktemp -d)
        if git clone --depth 1 --filter=blob:none --sparse https://github.com/anthropics/claude-code.git "$TEMP_DIR" 2>/dev/null; then
            cd "$TEMP_DIR"
            git sparse-checkout set plugins/ralph-wiggum 2>/dev/null || true
            if [ -d "$TEMP_DIR/plugins/ralph-wiggum" ]; then
                cp -r "$TEMP_DIR/plugins/ralph-wiggum" "$CLAUDE_DIR/plugins/"
                echo "✓ Ralph Wiggum plugin installed"
            else
                echo "⚠ Ralph Wiggum plugin not found in repo"
                echo "  Manual install: https://github.com/anthropics/claude-code/tree/main/plugins"
            fi
            cd - > /dev/null
        else
            echo "⚠ Could not clone claude-code repo"
            echo "  Manual install: git clone https://github.com/anthropics/claude-code.git /tmp/claude-code"
            echo "                  cp -r /tmp/claude-code/plugins/ralph-wiggum ~/.claude/plugins/"
        fi
        rm -rf "$TEMP_DIR"
    else
        echo "⚠ Git not found. Install Ralph Wiggum manually:"
        echo "  git clone https://github.com/anthropics/claude-code.git /tmp/claude-code"
        echo "  cp -r /tmp/claude-code/plugins/ralph-wiggum ~/.claude/plugins/"
    fi
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
