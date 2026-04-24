#!/bin/bash

set -ex

ORG="SoftwareStackSolutions"

# Take username as argument (from Terraform)
STUDENT_USER=$1

if [ -z "$STUDENT_USER" ]; then
  echo "GitHub username not provided"
  exit 1
fi

# Git Bash compatible path (IMPORTANT FIX)
GH_CMD="/c/Program Files/GitHub CLI/gh.exe"

REPOS=(
"digi_community_booktrack_auth"
"digi_community_booktrack_order"
"digi_community_booktrack_product"
"digi_community_booktrack_tracking"
"digi_community_booktrack_customerui"
"digi_community_booktrack_adminui"
"digi_community_booktrack_infra"
)

echo "Starting process for user: $STUDENT_USER"

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
  echo "Please login first:"
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

  # Clone if not exists
  if [ ! -d "$repo" ]; then
    git clone https://github.com/$ORG/$repo.git
  else
    echo "Folder exists, skipping clone"
  fi

  cd "$repo"

  # Remove old git history
  rm -rf .git

  # Create repo if not exists
  if "$GH_CMD" repo view "$STUDENT_USER/$repo" &> /dev/null; then
    echo "Repo already exists"
  else
    echo "Creating repo..."
    "$GH_CMD" repo create "$repo" \
      --public \
      --source=. \
      --remote=origin \
      --push \
      --owner "$STUDENT_USER"
  fi

  # Init & push (fallback if above didn't push)
  git init
  git add .

  if ! git diff --cached --quiet; then
    git commit -m "Initial commit"
  fi

  git branch -M main

  git remote remove origin 2>/dev/null || true
  git remote add origin https://github.com/$STUDENT_USER/$repo.git

  git push -u origin main --force || echo "Push failed, retry manually"

  cd ..
done

echo "All repos completed for $STUDENT_USER!"
