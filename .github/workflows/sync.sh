#!/bin/bash
# sync.sh
# Syncs changes from Company-Project to {{cookiecutter.project_name}} and creates a branch only if changes exist.

echo "Starting sync process..."
pwd

SOURCE="Company-Project/"
DEST="{{cookiecutter.project_name}}/"

# Parse variables from cookiecutter.json for dynamic exclusions
COOKIECUTTER_JSON="cookiecutter.json"
EXCLUDE_PATTERNS=()

for key in $(jq -r 'keys_unsorted[]' "$COOKIECUTTER_JSON"); do
    EXCLUDE_PATTERNS+=("--exclude=*{{ cookiecutter.$key }}*")
done

echo "Running rsync with content-based sync and exclusions..."
rsync -ac --ignore-existing --filter='merge Company-Project/.rsync-filter' "${EXCLUDE_PATTERNS[@]}" "$SOURCE" "$DEST"

# Check if there are any changes
if [ -z "$(git status --porcelain {{cookiecutter.project_name}})" ]; then
    echo "No changes detected in {{cookiecutter.project_name}}. Exiting..."
    exit 0
else
    echo "Changes detected. Preparing to create a branch..."
fi

# Configure git
git config user.name "github-actions"
git config user.email "github-actions@github.com"

# Commit and push changes to a new branch
BRANCH_NAME="sync-changes-$(date +%Y%m%d%H%M%S)"
git checkout -b "$BRANCH_NAME"
git add {{cookiecutter.project_name}}/
git commit -m "Sync updates from Company-Project to {{cookiecutter.project_name}}"
git push origin "$BRANCH_NAME"
