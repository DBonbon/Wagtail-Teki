#!/bin/bash

# Define paths
SOURCE_DIR="./Company-Project"
DESTINATION_DIR="./{{cookiecutter.project_name}}"
FILTER_FILE="${SOURCE_DIR}/.rsync-filter"

# Ensure the source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist."
    exit 1
fi

# Ensure the filter file exists
if [ ! -f "$FILTER_FILE" ]; then
    echo "Error: Filter file '$FILTER_FILE' does not exist in the source directory."
    exit 1
fi

# Create the destination directory if it doesn't exist
mkdir -p "$DESTINATION_DIR"

# Perform the synchronization using rsync
rsync -av \
    --filter=". ${FILTER_FILE}" \
    "$SOURCE_DIR/" "$DESTINATION_DIR/"

# Verify that no placeholders have been replaced or modified
# Check for any missing `{{cookiecutter.*}}` placeholders in the destination files
missing_placeholders=$(find "$DESTINATION_DIR" -type f -exec grep -L "{{cookiecutter." {} +)
if [ -n "$missing_placeholders" ]; then
    echo "Warning: Some files may have lost placeholders. Please verify:"
    echo "$missing_placeholders"
    exit 1
fi

echo "Sync completed successfully from '$SOURCE_DIR' to '$DESTINATION_DIR', with placeholders intact."
