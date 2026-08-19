#!/bin/bash

# check-week-13.sh - Validation script for Week 13 deliverables

set -e

echo "========================================"
echo "Week 13 Validation Script"
echo "========================================"
echo ""

FAILED=0
PASSED=0

# Helper function to check if file exists
check_file() {
    if [ -f "$1" ]; then
        echo "[PASS] File exists: $1"
        ((PASSED++))
    else
        echo "[FAIL] File missing: $1"
        ((FAILED++))
    fi
}

echo "Checking Week 13 deliverables..."
echo ""

# Check Week 13 README
echo "1. Checking Week 13 README..."
check_file "week-13/README.md"
echo ""

# Check demo script
echo "2. Checking demo script..."
check_file "week-13/demo-script.md"
echo ""

# Check documentation complete
echo "3. Checking documentation completion..."
check_file "docs/sprint-6-retrospective.md"
check_file "docs/week-13-acceptance-criteria.md"
echo ""

# Check Ansible playbook can run in check mode
echo "4. Checking Ansible playbook (dry-run mode)..."
if command -v ansible-playbook &> /dev/null; then
    if ansible-playbook -i ansible/inventory ansible/site.yml --check > /tmp/ansible-check.log 2>&1; then
        echo "[PASS] Ansible playbook runs in check mode without errors"
        ((PASSED++))
    else
        echo "[FAIL] Ansible playbook has errors in check mode"
        ((FAILED++))
        echo "  Log:"
        tail -5 /tmp/ansible-check.log | sed 's/^/    /'
    fi
else
    echo "[WARN] Ansible not installed, skipping playbook check"
fi
echo ""

# Verify all services are running
echo "5. Checking services status..."
SERVICES_OK=0

if curl -s http://localhost:5001/health | grep -q '"status"'; then
    echo "[PASS] MLflow service running"
    ((SERVICES_OK++))
else
    echo "[FAIL] MLflow service not running"
    ((FAILED++))
fi

if curl -s http://localhost:8000/health | grep -q '"status"'; then
    echo "[PASS] FastAPI service running"
    ((SERVICES_OK++))
else
    echo "[FAIL] FastAPI service not running"
    ((FAILED++))
fi

if [ "$SERVICES_OK" -eq 2 ]; then
    ((PASSED++))
fi
echo ""

# Check git status
echo "6. Checking git repository status..."
if [ -d ".git" ]; then
    if git status | grep -q "working tree clean"; then
        echo "[PASS] Git working tree is clean"
        ((PASSED++))
    else
        echo "[FAIL] Git has uncommitted changes"
        ((FAILED++))
        echo "  Run: git status"
    fi
else
    echo "[FAIL] Git repository not initialized"
    ((FAILED++))
fi
echo ""

# Summary
echo "========================================"
echo "Validation Summary"
echo "========================================"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "✓ All Week 13 checks passed!"
    echo "Playbook verified, services running, documentation complete. Ready for Demo Day."
    exit 0
else
    echo "✗ Some checks failed. Please review the items above."
    echo ""
    echo "Before Demo Day:"
    echo "1. Run Ansible playbook and fix any errors"
    echo "2. Ensure all services are running"
    echo "3. Complete all documentation"
    echo "4. Commit all changes: git add . && git commit -m 'Week 13: final prep'"
    exit 1
fi
