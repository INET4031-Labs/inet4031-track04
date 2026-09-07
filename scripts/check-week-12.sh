#!/bin/bash

# check-week-12.sh - Validation script for Week 12 deliverables

set -e

echo "========================================"
echo "Week 12 Validation Script"
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

echo "Checking Week 12 deliverables..."
echo ""

# Check Week 12 README
echo "1. Checking Week 12 README..."
check_file "week-12/README.md"
echo ""

# Check FastAPI inference server
echo "2. Checking FastAPI inference server..."
check_file "week-12/inference-server.py"
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

# Check FastAPI service
echo "4. Checking FastAPI service..."
if curl -s http://localhost:8000/health | grep -q '"status"'; then
    echo "[PASS] FastAPI health check passed"
    PASSED=$((PASSED + 1))
else
    echo "[FAIL] FastAPI health check failed or service not running"
    FAILED=$((FAILED + 1))
fi
echo ""

# Check test pipeline script
echo "5. Checking test pipeline script..."
check_file "week-12/test-pipeline.sh"
echo ""

# Check Ansible FastAPI service template
echo "6. Checking Ansible FastAPI service template..."
check_file "ansible/roles/mlflow/templates/fastapi.service.j2"
echo ""

# Check that FastAPI is in Ansible tasks
echo "7. Checking Ansible includes FastAPI..."
if grep -q "fastapi" ansible/roles/mlflow/tasks/main.yml; then
    echo "[PASS] FastAPI installation found in Ansible tasks"
    PASSED=$((PASSED + 1))
else
    echo "[FAIL] FastAPI installation not found in Ansible tasks"
    FAILED=$((FAILED + 1))
fi
echo ""

# Check git commits
echo "8. Checking git status..."
if [ -d ".git" ]; then
    COMMITS=$(git log --oneline | wc -l)
    if [ "$COMMITS" -gt 1 ]; then
        echo "[PASS] Git commits found ($COMMITS commits)"
        PASSED=$((PASSED + 1))
    else
        echo "[FAIL] No git commits found (expected at least Week 10 and 11)"
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
    echo "✓ All Week 12 checks passed!"
    echo "MLflow and FastAPI services are running and ready for Flask integration."
    exit 0
else
    echo "✗ Some checks failed. Please review the items above."
    echo ""
    echo "Common issues:"
    echo "- FastAPI not running: ensure 'python3 week-12/inference-server.py' is started"
    echo "- MLflow down: restart with 'mlflow server --host 0.0.0.0 --port 5001'"
    echo "- Inference server missing: create week-12/inference-server.py from template"
    exit 1
fi
