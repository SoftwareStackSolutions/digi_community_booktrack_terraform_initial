#!/bin/bash

ORG="SoftwareStackSolutions"

REPOS=(
"digi_community_booktrack_auth"
"digi_community_booktrack_order"
"digi_community_booktrack_product"
"digi_community_booktrack_tracking"
"digi_community_booktrack_customerui"
"digi_community_booktrack_adminui"
"digi_community_booktrack_infra"
)

for repo in "${REPOS[@]}"
do
  echo "Cloning $repo..."
  git clone https://github.com/$ORG/$repo.git
done

echo "All repositories cloned successfully!"