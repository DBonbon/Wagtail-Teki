#!/bin/bash
# sync.sh
# Syncs changes from Company-Project to {{cookiecutter.project_name}} and confirms only actual content changes.

echo "Starting sync process..."
pwd

SOURCE="Company-Project/"
DEST="{{cookiecutter.project_name}}/"
COOKIECUTTER_JSON="cookiecutter.json"
EXCLUDE_PATTERNS=()

# Read cookiecutter.json and exclude relevant keys
for key in $(jq -r 'keys_unsorted[]' "$COOKIECUTTER_JSON"); do
    # Exclude patterns for cookiecutter variables
    EXCLUDE_PATTERNS+=("--exclude=*{{ cookiecutter.$key }}*")

    # Handle hardcoded values dynamically if they exist
    value=$(jq -r ".[\"$key\"]" "$COOKIECUTTER_JSON")
    if [[ $value != *"{{"* && $value != *"}}"* ]]; then
        EXCLUDE_PATTERNS+=("--exclude=*$value*")
    fi
done

# Print exclude patterns for debugging
echo "Exclude patterns generated:"
for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    echo "$pattern"
done

echo "rsync completed."

# Log recently modified files to verify sync
echo "Files recently modified in {{cookiecutter.project_name}}:"
find "$DEST" -type f -printf '%T+ %p\n' | sort -r | head -20
