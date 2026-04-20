#!/bin/bash

set -e

# ========= CONFIG =========
SOURCE_ORG="SoftwareStackSolutions"
BASE_DIR="$HOME/booktrack-app"

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

echo "Starting EC2 setup..."

# ========= INSTALLATION =========
echo "Installing Git..."
sudo yum install -y git

echo "Installing Docker..."
sudo yum install -y docker

echo "Starting Docker..."
sudo systemctl start docker
sudo systemctl enable docker

echo "Adding user to Docker group..."
sudo usermod -aG docker ec2-user || true

# Apply group change immediately (without logout)
newgrp docker <<EONG
echo "Docker group applied"
EONG

# ========= VERIFY =========
echo "Verifying installations..."
git --version
docker --version

# ========= CLONE =========
echo "Creating project directory..."
mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

for repo in "${REPOS[@]}"; do
  echo "Cloning $repo..."

  git clone "https://github.com/$SOURCE_ORG/$repo.git"

  cd "$repo"

  # Add upstream (optional)
  git remote add upstream "https://github.com/$SOURCE_ORG/$repo.git" 2>/dev/null || true

  echo "Cloned $repo"

  # ========= BUILD =========
  if [ -f "Dockerfile" ]; then
    echo "Building Docker image for $repo..."
    docker build -t "$repo:latest" .
  else
    echo "No Dockerfile found in $repo, skipping build"
  fi

  cd ..
done

echo "Setup complete!"
echo "Location: $BASE_DIR"
