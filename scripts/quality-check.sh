#!/bin/bash
# Code Quality Gate
# Enforces /base skill rules via CodeGraphContext (cgc)
# Usage: ./scripts/quality-check.sh [path]
#
# Rules enforced:
#   - Cyclomatic complexity <= 10 per function
#   - Dead code detection
#   - Security static analysis (if available)
#
# Prerequisites: cgc CLI (pip install codegraphcontext)

set -e

# Auto-detect cgc binary
CGC=$(command -v cgc 2>/dev/null || echo "")
if [ -z "$CGC" ]; then
    echo "Warning: cgc not found. Install with: pip install codegraphcontext"
    echo "Skipping CodeGraphContext checks."
    CGC_AVAILABLE=false
else
    CGC_AVAILABLE=true
fi

PROJECT_DIR="${1:-$(pwd)}"
COMPLEXITY_LIMIT=10
FAILED=0

echo "=== Quality Gate ==="
echo "Target: $PROJECT_DIR"
echo ""

# --- Check 1: Cyclomatic Complexity (requires cgc) ---
if [ "$CGC_AVAILABLE" = true ]; then
    echo "Indexing codebase..."
    $CGC index "$PROJECT_DIR" --force 2>/dev/null || {
        echo "Warning: indexing failed, using cached graph"
    }

    echo ""
    echo "1. Checking cyclomatic complexity (max: $COMPLEXITY_LIMIT)..."
    COMPLEXITY_OUTPUT=$($CGC analyze complexity --threshold $COMPLEXITY_LIMIT 2>&1)

    EXCEED_COUNT=$(echo "$COMPLEXITY_OUTPUT" | grep -oE '[0-9]+ function\(s\) exceed' | grep -oE '^[0-9]+' || echo "0")
    if [ "$EXCEED_COUNT" -gt 0 ]; then
        echo "   FAIL: $EXCEED_COUNT functions exceeding complexity $COMPLEXITY_LIMIT:"
        echo "$COMPLEXITY_OUTPUT"
        FAILED=1
    else
        echo "   OK: All functions within complexity limit"
    fi
else
    echo "1. Skipping complexity check (cgc not installed)"
fi

# --- Check 2: Security Static Analysis ---
echo ""
echo "2. Running security checks..."

# Python: Bandit
if [ -f "pyproject.toml" ] || [ -d "src" ]; then
    if command -v bandit &>/dev/null; then
        echo "   Running Bandit..."
        bandit -r src/ -q 2>/dev/null || {
            echo "   FAIL: Bandit detected security issues"
            FAILED=1
        }
    elif command -v uv &>/dev/null && uv run python -c "import bandit" 2>/dev/null; then
        echo "   Running Bandit (via uv)..."
        uv run bandit -r src/ -q 2>/dev/null || {
            echo "   FAIL: Bandit detected security issues"
            FAILED=1
        }
    else
        echo "   Skipping Bandit (not installed)"
    fi
fi

# JavaScript/TypeScript: npm audit
if [ -f "package-lock.json" ]; then
    echo "   Running npm audit..."
    npm audit --production 2>/dev/null || {
        echo "   Warning: npm audit found vulnerabilities (review, not blocking)"
    }
fi

# Python: Safety
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    if command -v safety &>/dev/null; then
        echo "   Running Safety..."
        safety check 2>/dev/null || {
            echo "   Warning: Safety detected potential dependency vulnerabilities"
        }
    fi
fi

# --- Check 3: Dead Code (requires cgc) ---
if [ "$CGC_AVAILABLE" = true ]; then
    echo ""
    echo "3. Checking dead code..."
    DEAD_OUTPUT=$($CGC analyze dead-code --exclude route,handler,task,api,event,webhook,test 2>&1)

    if echo "$DEAD_OUTPUT" | grep -qiE "unused|dead"; then
        echo "   Warning: Potentially unused code detected (review, not blocking):"
        echo "$DEAD_OUTPUT" | head -20
    else
        echo "   OK: No dead code detected"
    fi
else
    echo ""
    echo "3. Skipping dead code check (cgc not installed)"
fi

# --- Check 4: Stats Summary (requires cgc) ---
if [ "$CGC_AVAILABLE" = true ]; then
    echo ""
    echo "4. Codebase stats..."
    $CGC stats 2>/dev/null || true
fi

# --- Result ---
echo ""
if [ $FAILED -eq 1 ]; then
    echo "=== Quality Gate FAILED ==="
    echo "Fix violations before committing."
    if [ "$CGC_AVAILABLE" = true ]; then
        echo "Run: cgc analyze complexity --threshold $COMPLEXITY_LIMIT --visual"
    fi
    exit 1
else
    echo "=== Quality Gate PASSED ==="
fi
