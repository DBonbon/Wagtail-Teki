#!/bin/bash

# Define paths relative to the .github/workflows directory
SOURCE="../Company-Project"
TEMPLATE="../{{cookiecutter.project_name}}"
EXCLUDE_FILE="../exclude-retrocookie.txt"

# Generate the exclude flags from the file
EXCLUDE_FLAGS=()
if [ -f "$EXCLUDE_FILE" ]; then
  while IFS= read -r line; do
    # Skip empty lines or comments
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    EXCLUDE_FLAGS+=("--exclude=$line")
  done < "$EXCLUDE_FILE"
else
  echo "Exclude file not found: $EXCLUDE_FILE"
  exit 1
fi

# Run Retrocookie
echo "Running Retrocookie with the following exclusions:"
printf '%s\n' "${EXCLUDE_FLAGS[@]}"
retrocookie \
  --template "$TEMPLATE" \
  --source "$SOURCE" \
  "${EXCLUDE_FLAGS[@]}"

if [ $? -eq 0 ]; then
  echo "Retrocookie completed successfully."
else
  echo "Retrocookie encountered an error."
  exit 1
fi
