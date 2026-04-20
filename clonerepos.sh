#!/bin/bash

# ========= CONFIG =========
SOURCE_ORG="SoftwareStackSolutions"
BASE_DIR="$HOME/booktrack-app"

# If repos are private → use PAT
# export GITHUB_TOKEN="your_token_here"

REPOS=(
  "digi_community_booktrack_genericicicd"
  "digi_community_booktrack_auth"
  "digi_community_booktrack_order"
  "digi_community_booktrack_product"
  "digi_community_booktrack_tracking"
  "digi_community_booktrack_customerui"
  "digi_community_booktrack_adminui"
  "digi_community_booktrack_infra"
  "digi_community_booktrack_terraform_initial"
)

# ========= SETUP =========
echo "Creating base directory..."
mkdir -p "$BASE_DIR"
cd "$BASE_DIR" || exit

# ========= CLONE =========
for repo in "${REPOS[@]}"; do
  echo "Cloning $repo..."

  # If public repo
  git clone "https://github.com/$SOURCE_ORG/$repo.git"

  # If private repo (use this instead)
  # git clone "https://$GITHUB_TOKEN@github.com/$SOURCE_ORG/$repo.git"

  cd "$repo" || exit

  # Add upstream (optional)
  git remote add upstream "https://github.com/$SOURCE_ORG/$repo.git" 2>/dev/null

  echo "Cloned $repo"

  # ========= OPTIONAL BUILD =========
  if [ -f "Dockerfile" ]; then
    echo "Building Docker image for $repo..."
    docker build -t "$repo:latest" .
  fi

  cd ..
done

echo "All repositories cloned and ready in $BASE_DIR"
