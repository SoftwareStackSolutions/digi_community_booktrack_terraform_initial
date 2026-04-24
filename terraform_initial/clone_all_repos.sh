#!/bin/bash

set -e

ORG="SoftwareStackSolutions"
STUDENT_USER="ASHWINISHEEBHA"

#  FULL PATH to gh (IMPORTANT)
GH_CMD="C:\Program Files\GitHub CLI\gh.exe"

REPOS=(
"digi_community_booktrack_auth"
"digi_community_booktrack_order"
"digi_community_booktrack_product"
"digi_community_booktrack_tracking"
"digi_community_booktrack_customerui"
"digi_community_booktrack_adminui"
"digi_community_booktrack_infra"
)

echo "Starting process..."

# -----------------------------
# Check gh exists
# -----------------------------
if [ ! -f "$GH_CMD" ]; then
  echo "GitHub CLI not found at $GH_CMD"
  exit 1
else
  echo "Using GH CLI at: $GH_CMD"
fi

# -----------------------------
# Check Authentication
# -----------------------------
if ! "$GH_CMD" auth status &> /dev/null
then
  echo "Not logged in. Run this manually once:"
  echo "gh auth login"
  exit 1
else
  echo "Already authenticated"
fi

# -----------------------------
# Process repos
# -----------------------------
for repo in "${REPOS[@]}"
do
  echo "=================================="
  echo "Processing $repo"

  # Clone
  if [ -d "$repo" ]; then
    echo "Folder exists, skipping clone"
  else
    git clone https://github.com/$ORG/$repo.git
  fi

  cd "$repo"

  # Remove old git history
  rm -rf .git

  # Create repo if not exists
  if "$GH_CMD" repo view "$STUDENT_USER/$repo" &> /dev/null; then
    echo "Repo already exists"
  else
    echo "Creating repo..."
    "$GH_CMD" repo create "$STUDENT_USER/$repo" --public --confirm
  fi

  # Init & push
  git init
  git add .

  if git diff --cached --quiet; then
    echo "Nothing to commit"
  else
    git commit -m "Initial commit"
  fi

  git branch -M main

  git remote remove origin 2>/dev/null || true
  git remote add origin https://github.com/$STUDENT_USER/$repo.git

  git push -u origin main --force

  cd ..
done

echo "All repos completed!"
