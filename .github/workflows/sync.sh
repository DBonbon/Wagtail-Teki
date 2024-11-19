#!/bin/bash
# sync.sh
# Syncs changes from Company-Project to {{cookiecutter.project_name}} and confirms only actual content changes

echo "Starting sync process..."
pwd

SOURCE="Company-Project/"
DEST="{{cookiecutter.project_name}}/"
COOKIECUTTER_JSON="cookiecutter.json"
EXCLUDE_PATTERNS=()

# Read cookiecutter.json and exclude relevant paths
for key in $(jq -r 'keys_unsorted[]' "$COOKIECUTTER_JSON"); do
    EXCLUDE_PATTERNS+=("--exclude=*{{ cookiecutter.$key }}*")
done

# Run rsync with specified exclusions
rsync -ac --filter='merge Company-Project/.rsync-filter' "${EXCLUDE_PATTERNS[@]}" "$SOURCE" "$DEST" > /dev/null
echo "rsync completed."

# Log recently modified files to verify sync
echo "Files recently modified in {{cookiecutter.project_name}}:"
find "$DEST" -type f -printf '%T+ %p\n' | sort -r | head -20
