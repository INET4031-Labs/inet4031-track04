#!/bin/bash

# init-git.sh - Initialize git repository for track-04

set -e

echo "Initializing git repository for track-04-machine-learning-and-ai..."

# Initialize git if not already initialized
if [ ! -d ".git" ]; then
    git init
    echo "Git repository initialized"
else
    echo "Git repository already exists"
fi

# Add all files
git add .

# Create initial commit
git commit -m "Week 10: Track 4 scaffold - MLflow, FastAPI, Flask integration for ML pipeline" || echo "Nothing to commit or already committed"

# Show status
echo ""
echo "Git repository status:"
git status

echo ""
echo "Recent commits:"
git log --oneline -5

echo ""
echo "✓ Git repository ready"
