#!/bin/bash
# selective_sync_base_contains.sh
# Sync base.py while skipping lines containing cookiecutter variables.

SOURCE="Company-Project/src/teki/settings/base.py"
DEST="{{cookiecutter.project_name}}/src/teki/settings/base.py"
COOKIECUTTER_PATTERN="{{cookiecutter"

echo "Starting selective sync test for base.py..."

# Ensure source file exists
if [[ ! -f "$SOURCE" ]]; then
    echo "Source file $SOURCE does not exist. Exiting."
    exit 1
fi

# Ensure destination file exists
if [[ ! -f "$DEST" ]]; then
    echo "Destination file $DEST does not exist. Creating it."
    mkdir -p "$(dirname "$DEST")"
    cp "$SOURCE" "$DEST"
    exit 0
fi

# Create a temporary file for processing
TEMP_DEST="${DEST}.temp"

echo "Processing file: $SOURCE -> $DEST"
echo "Logging changes for review..."

# Initialize temp file
> "$TEMP_DEST"

# Line-by-line processing
while IFS= read -r line; do
    if [[ "$line" == *"$COOKIECUTTER_PATTERN"* ]]; then
        echo "[SKIP] Preserving cookiecutter variable: $line" >> sync_debug.log
        # Keep the original line from the destination
        grep -F "$line" "$DEST" >> "$TEMP_DEST" || echo "$line" >> "$TEMP_DEST"
    else
        echo "[SYNC] Updating line: $line" >> sync_debug.log
        # Copy the line from the source to the temp file
        echo "$line" >> "$TEMP_DEST"
    fi
done < "$SOURCE"

# Compare the result and apply changes
if ! diff "$TEMP_DEST" "$DEST" >/dev/null; then
    echo "Changes detected. Overwriting $DEST."
    mv "$TEMP_DEST" "$DEST"
else
    echo "No changes detected for $DEST."
    rm -f "$TEMP_DEST"
fi

# Cleanup
rm -f "$TEMP_DEST"
echo "Selective sync for base.py completed. Check sync_debug.log for details."
