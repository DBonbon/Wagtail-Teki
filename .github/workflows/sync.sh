#!/bin/bash

echo "Starting local sync process..."

# Define source and destination paths
SOURCE="Company-Project/"
DEST="{{cookiecutter.project_name}}/"
COOKIECUTTER_JSON="cookiecutter.json"

# Temporary file for exclusions
TMP_EXCLUDE_FILE=$(mktemp)

# Add cookiecutter variable exclusions dynamically, ensuring only strings are processed
echo "Adding cookiecutter variable exclusions..."
jq -r 'to_entries[] | select(.value | type == "string") | "--exclude=*{{ cookiecutter." + .key + " }}*"' "$COOKIECUTTER_JSON" >> "$TMP_EXCLUDE_FILE"

# Add static exclusions
echo "Adding static exclusions..."
cat <<EOL >> "$TMP_EXCLUDE_FILE"
- /frontend/.next/
- /frontend/node_modules/
- /src/static/django_extensions/
- /src/static/wagtail_localize/
- /deploy/keys/
- /src/**/__pycache__/
- /src/**/*.pyc
- /.env
- /.env.local
EOL

# Run rsync with exclusions
echo "Running rsync..."
rsync -ac --filter="merge $TMP_EXCLUDE_FILE" "$SOURCE" "$DEST" > /dev/null 2>&1

# Clean up
rm "$TMP_EXCLUDE_FILE"

echo "Sync completed successfully."
