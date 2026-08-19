#!/bin/bash

# check-week-10.sh - Validation script for Week 10 deliverables

set -e

echo "========================================"
echo "Week 10 Validation Script"
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

# Helper function to check if directory exists
check_dir() {
    if [ -d "$1" ]; then
        echo "[PASS] Directory exists: $1"
        ((PASSED++))
    else
        echo "[FAIL] Directory missing: $1"
        ((FAILED++))
    fi
}

echo "Checking Week 10 deliverables..."
echo ""

# Check week-10 README
echo "1. Checking Week 10 README..."
check_file "week-10/README.md"
echo ""

# Check architecture decision document
echo "2. Checking architecture decision record..."
check_file "week-10/architecture-decision.md"
echo ""

# Check backlog files
echo "3. Checking Week 11 backlog..."
check_file "week-11/backlog.md"
echo ""

echo "4. Checking Week 12 backlog..."
check_file "week-12/backlog.md"
echo ""

# Check Ansible role structure
echo "5. Checking Ansible role directory..."
check_dir "ansible/roles/mlflow"
check_dir "ansible/roles/mlflow/tasks"
check_dir "ansible/roles/mlflow/handlers"
check_dir "ansible/roles/mlflow/defaults"
check_dir "ansible/roles/mlflow/vars"
check_dir "ansible/roles/mlflow/templates"
echo ""

# Check Ansible role files
echo "6. Checking Ansible role files..."
check_file "ansible/roles/mlflow/tasks/main.yml"
check_file "ansible/roles/mlflow/handlers/main.yml"
check_file "ansible/roles/mlflow/defaults/main.yml"
check_file "ansible/roles/mlflow/vars/main.yml"
echo ""

# Check documentation structure
echo "7. Checking documentation files..."
check_file "docs/environment-log.md"
check_file "docs/week-10-acceptance-criteria.md"
check_file "docs/week-11-acceptance-criteria.md"
check_file "docs/week-12-acceptance-criteria.md"
check_file "docs/week-13-acceptance-criteria.md"
check_file "docs/week-14-acceptance-criteria.md"
check_file "docs/sprint-5-retrospective.md"
check_file "docs/sprint-6-retrospective.md"
check_file "docs/sprint-7-retrospective.md"
echo ""

# Check git status
echo "8. Checking git repository..."
if [ -d ".git" ]; then
    echo "[PASS] Git repository initialized"
    ((PASSED++))
else
    echo "[FAIL] Git repository not initialized"
    ((FAILED++))
fi

if [ -f ".gitignore" ]; then
    echo "[PASS] .gitignore file exists"
    ((PASSED++))
else
    echo "[FAIL] .gitignore file missing"
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
    echo "✓ All Week 10 checks passed!"
    exit 0
else
    echo "✗ Some checks failed. Please review the items above."
    exit 1
fi
