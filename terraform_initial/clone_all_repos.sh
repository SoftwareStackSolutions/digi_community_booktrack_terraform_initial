#!/bin/bash

set -ex

SOURCE_ORG="SoftwareStackSolutions"

# INPUTS
STUDENT_USER=$1
TARGET_ORG=$2

if [ -z "$STUDENT_USER" ]; then
  echo "Usage: ./clone_all_repos.sh <github_username> [target_org]"
  exit 1
fi

# Decide owner
if [ -n "$TARGET_ORG" ]; then
  OWNER="$TARGET_ORG"
  echo "Using TARGET ORG: $OWNER"
else
  OWNER="$STUDENT_USER"
  echo "Using USER account: $OWNER"
fi

GH_CMD="/c/Program Files/GitHub CLI/gh.exe"

REPOS=(
"digi_community_booktrack_auth"
"digi_community_booktrack_order"
"digi_community_booktrack_product"
"digi_community_booktrack_tracking"
"digi_community_booktrack_customerui"
"digi_community_booktrack_adminui"
"digi_community_booktrack_infra"
"digi_community_booktrack_artifact"
)

echo "Starting process for owner: $OWNER"

# -----------------------------
# Check gh
# -----------------------------
if [ ! -f "$GH_CMD" ]; then
  echo "GitHub CLI not found at $GH_CMD"
  exit 1
fi

# -----------------------------
# Check auth
# -----------------------------
if ! "$GH_CMD" auth status &> /dev/null; then
  echo "Run: gh auth login"
  exit 1
fi

# -----------------------------
# Process repos
# -----------------------------
for repo in "${REPOS[@]}"
do
  echo "=================================="
  echo "Processing $repo"

  NEW_REPO_NAME="$repo"

  # Clone if not exists
  if [ ! -d "$repo" ]; then
    git clone https://github.com/$SOURCE_ORG/$repo.git
  else
    echo "Folder exists, skipping clone"
  fi

  cd "$repo"

  # Remove old git history
  rm -rf .git

  # Init fresh repo
  git init
  git add .

  if ! git diff --cached --quiet; then
    git commit -m "Initial commit"
  fi

  git branch -M main

  # -----------------------------
  # Create repo
  # -----------------------------
  if "$GH_CMD" repo view "$OWNER/$NEW_REPO_NAME" &> /dev/null; then
    echo "Repo already exists: $NEW_REPO_NAME"
  else
    echo "Creating repo: $NEW_REPO_NAME under $OWNER"

    if [ "$OWNER" == "$STUDENT_USER" ]; then
      # Create under USER
      "$GH_CMD" repo create "$NEW_REPO_NAME" \
        --public \
        --source=. \
        --remote=origin \
        --push
    else
      # Create under ORG
      "$GH_CMD" repo create "$OWNER/$NEW_REPO_NAME" \
        --public \
        --source=. \
        --remote=origin \
        --push
    fi
  fi

  # -----------------------------
  # Ensure remote & push
  # -----------------------------
  git remote remove origin 2>/dev/null || true
  git remote add origin https://github.com/$OWNER/$NEW_REPO_NAME.git

  git push -u origin main --force || echo "Push failed"

  cd ..
done

echo "All repos completed for $OWNER!"