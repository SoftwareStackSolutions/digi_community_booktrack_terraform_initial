#!/bin/bash

set -e

SOURCE_ORG="SoftwareStackSolutions"

# INPUTS
STUDENT_USER=$1
TARGET_ORG=$2

if [ -z "$STUDENT_USER" ]; then
    echo "Usage: ./sync_all_repos.sh <github_username> [target_org]"
    exit 1
fi

# Determine owner
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

# Check GitHub CLI
if [ ! -f "$GH_CMD" ]; then
    echo "GitHub CLI not found at:"
    echo "$GH_CMD"
    exit 1
fi

# Check auth
if ! "$GH_CMD" auth status >/dev/null 2>&1; then
    echo "Please login first:"
    echo "gh auth login"
    exit 1
fi

echo ""
echo "========================================"
echo "Owner: $OWNER"
echo "Source Org: $SOURCE_ORG"
echo "========================================"
echo ""

for repo in "${REPOS[@]}"
do
    echo ""
    echo "========================================"
    echo "Processing: $repo"
    echo "========================================"

    STUDENT_REPO="$OWNER/$repo"

    # ---------------------------------------------------
    # REPO DOES NOT EXIST => CREATE IT
    # ---------------------------------------------------
    if ! "$GH_CMD" repo view "$STUDENT_REPO" >/dev/null 2>&1; then

        echo "Repository does not exist."
        echo "Creating $STUDENT_REPO"

        rm -rf "$repo"

        git clone "https://github.com/$SOURCE_ORG/$repo.git"

        cd "$repo"

        if [ "$OWNER" = "$STUDENT_USER" ]; then

            "$GH_CMD" repo create "$repo" \
                --public \
                --source=. \
                --remote=origin \
                --push

        else

            "$GH_CMD" repo create "$STUDENT_REPO" \
                --public \
                --source=. \
                --remote=origin \
                --push

        fi

        cd ..
        rm -rf "$repo"

        echo "Repository created."

    else

        # ---------------------------------------------------
        # REPO EXISTS => SYNC NEW CHANGES ONLY
        # ---------------------------------------------------

        echo "Repository already exists."
        echo "Syncing latest changes..."

        rm -rf "$repo"

        git clone "https://github.com/$OWNER/$repo.git"

        cd "$repo"

        # Add upstream if missing
        if ! git remote | grep -q "^upstream$"; then
            git remote add upstream \
            "https://github.com/$SOURCE_ORG/$repo.git"
        fi

        git fetch upstream

        git checkout main

        echo "Merging upstream changes..."

        git merge upstream/main --no-edit || {
            echo ""
            echo "====================================="
            echo "MERGE CONFLICT DETECTED"
            echo "Repo: $repo"
            echo "Student must resolve manually."
            echo "====================================="
            cd ..
            continue
        }

        git push origin main

        cd ..
        rm -rf "$repo"

        echo "Sync completed."
    fi
done

echo ""
echo "========================================"
echo "All repositories processed successfully."
echo "========================================"
