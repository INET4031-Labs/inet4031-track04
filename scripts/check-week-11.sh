#!/bin/bash

# check-week-11.sh - Validation script for Week 11 deliverables

set -e

echo "========================================"
echo "Week 11 Validation Script"
echo "========================================"
echo ""

FAILED=0
PASSED=0

# Helper function to check if file exists
check_file() {
    if [ -f "$1" ]; then
        echo "[PASS] File exists: $1"
        PASSED=$((PASSED + 1))
    else
        echo "[FAIL] File missing: $1"
        FAILED=$((FAILED + 1))
    fi
}

echo "Checking Week 11 deliverables..."
echo ""

# Check Week 11 README
echo "1. Checking Week 11 README..."
check_file "week-11/README.md"
echo ""

# Check training scripts
echo "2. Checking training scripts..."
check_file "week-11/fetch-incidents.py"
check_file "week-11/train-model.py"
echo ""

# Check MLflow service
echo "3. Checking MLflow service..."
if curl -s http://localhost:5001/health | grep -q '"status"'; then
    echo "[PASS] MLflow health check passed"
    PASSED=$((PASSED + 1))
else
    echo "[FAIL] MLflow health check failed or service not running"
    FAILED=$((FAILED + 1))
fi
echo ""

# Check Ansible role content
echo "4. Checking Ansible role content..."
if grep -q "mlflow" ansible/roles/mlflow/tasks/main.yml; then
    echo "[PASS] MLflow installation tasks found"
    PASSED=$((PASSED + 1))
else
    echo "[FAIL] MLflow installation tasks missing"
    FAILED=$((FAILED + 1))
fi
echo ""

# Check site.yml includes mlflow role
echo "5. Checking site.yml includes mlflow role..."
if grep -q "mlflow" ansible/site.yml; then
    echo "[PASS] MLflow role included in site.yml"
    PASSED=$((PASSED + 1))
else
    echo "[FAIL] MLflow role not included in site.yml"
    FAILED=$((FAILED + 1))
fi
echo ""

# Check git commits
echo "6. Checking git status..."
if [ -d ".git" ]; then
    COMMITS=$(git log --oneline | wc -l)
    if [ "$COMMITS" -gt 0 ]; then
        echo "[PASS] Git commits found ($COMMITS commits)"
        PASSED=$((PASSED + 1))
    else
        echo "[FAIL] No git commits found"
        FAILED=$((FAILED + 1))
    fi
else
    echo "[FAIL] Git repository not initialized"
    FAILED=$((FAILED + 1))
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
    echo "✓ All Week 11 checks passed!"
    echo "MLflow server is running and model training components are in place."
    exit 0
else
    echo "✗ Some checks failed. Please review the items above."
    echo ""
    echo "Common issues:"
    echo "- MLflow not running: ensure 'mlflow server' is started"
    echo "- Training scripts missing: create week-11/train-model.py and week-11/fetch-incidents.py"
    echo "- Ansible tasks missing: add mlflow installation to ansible/roles/mlflow/tasks/main.yml"
    exit 1
fi
