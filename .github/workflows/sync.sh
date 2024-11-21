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
echo "Generating exclude patterns from cookiecutter.json..."
for key in $(jq -r 'keys_unsorted[]' "$COOKIECUTTER_JSON"); do
    # Exclude patterns for explicit cookiecutter variables
    EXCLUDE_PATTERNS+=("--exclude=*{{ cookiecutter.$key }}*")

    # Handle implicit cookiecutter variables dynamically
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

# Run rsync with a dry run for debugging
echo "Running rsync (dry run)..."
rsync -navc --filter='merge Company-Project/.rsync-filter' "${EXCLUDE_PATTERNS[@]}" "$SOURCE" "$DEST"

# Run actual rsync
echo "Running rsync (actual)..."
rsync -avc --filter='merge Company-Project/.rsync-filter' "${EXCLUDE_PATTERNS[@]}" "$SOURCE" "$DEST"

echo "rsync completed."

# Log files recently modified in destination directory
echo "Files recently modified in {{cookiecutter.project_name}}:"
find "$DEST" -type f -printf '%T+ %p\n' | sort -r | head -20

# Debugging the source and destination directories
echo "Source directory content:"
ls -la "$SOURCE"

echo "Destination directory content after sync:"
ls -la "$DEST"
