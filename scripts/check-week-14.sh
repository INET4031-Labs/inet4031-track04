#!/bin/bash

# check-week-14.sh - Validation script for Week 14 deliverables (Demo Day)

set -e

echo "========================================"
echo "Week 14 Validation Script (Demo Day)"
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

echo "Checking Week 14 (Demo Day) deliverables..."
echo ""

# Check Week 14 README
echo "1. Checking Week 14 README..."
check_file "week-14/README.md"
echo ""

# Check demo day log
echo "2. Checking demo day log..."
check_file "week-14/demo-day-log.md"
echo ""

# Check final documentation
echo "3. Checking final documentation..."
check_file "docs/qa-report-14.md"
check_file "docs/sprint-14-retrospective.md"
echo ""

# Verify all services are running after rebuild
echo "4. Checking services after rebuild..."
SERVICES_OK=0

if curl -s http://localhost:5001/health | grep -q '"status"'; then
    echo "[PASS] MLflow service running"
    ((SERVICES_OK++))
else
    echo "[FAIL] MLflow service not running"
    FAILED=$((FAILED + 1))
fi

if curl -s http://localhost:8000/health | grep -q '"status"'; then
    echo "[PASS] FastAPI service running"
    ((SERVICES_OK++))
else
    echo "[FAIL] FastAPI service not running"
    FAILED=$((FAILED + 1))
fi

if [ "$SERVICES_OK" -eq 2 ]; then
    PASSED=$((PASSED + 1))
fi
echo ""

# Check that model is trained
echo "5. Checking model is registered..."
if python3 -c "import mlflow; mlflow.set_tracking_uri('http://localhost:5001'); models = mlflow.search_registered_models(); print('Found', len(models), 'models')" 2>/dev/null | grep -q "Found"; then
    echo "[PASS] Model found in MLflow registry"
    PASSED=$((PASSED + 1))
else
    echo "[FAIL] No model found in MLflow registry (may need to retrain)"
    FAILED=$((FAILED + 1))
fi
echo ""

# Test end-to-end pipeline
echo "6. Testing end-to-end pipeline..."
if [ -f "week-12/test-pipeline.sh" ]; then
    if bash week-12/test-pipeline.sh > /tmp/pipeline-test.log 2>&1; then
        echo "[PASS] End-to-end pipeline test passed"
        PASSED=$((PASSED + 1))
    else
        echo "[FAIL] End-to-end pipeline test failed"
        FAILED=$((FAILED + 1))
        echo "  See: cat /tmp/pipeline-test.log"
    fi
else
    echo "[WARN] Pipeline test script not found, skipping"
fi
echo ""

# Check git status
echo "7. Checking git repository status..."
if [ -d ".git" ]; then
    if git status | grep -q "working tree clean"; then
        echo "[PASS] Git working tree is clean"
        PASSED=$((PASSED + 1))
    else
        echo "[FAIL] Git has uncommitted changes"
        FAILED=$((FAILED + 1))
        echo "  Uncommitted files:"
        git status --short | sed 's/^/    /'
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
    echo "✓ All Week 14 checks passed!"
    echo "Environment rebuilt successfully. Ready for Demo Day presentation."
    exit 0
else
    echo "✗ Some checks failed. Please review before Demo Day."
    echo ""
    echo "Priority fixes:"
    echo "1. If services not running: run Ansible playbook again"
    echo "2. If model not found: run 'python3 week-11/train-model.py' to retrain"
    echo "3. If git dirty: commit pending changes with 'git commit -am \"Week 14 fixes\"'"
    echo "4. If pipeline test fails: check service logs with 'sudo journalctl -u mlflow/fastapi -n 50'"
    exit 1
fi
