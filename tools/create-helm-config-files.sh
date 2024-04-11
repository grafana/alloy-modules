#!/bin/bash

# Source directory where the .alloy files are located
SOURCE_DIR="/modules"

# Destination directory where you want to copy the .alloy files
DEST_DIR="/helm/alloy-modules/configmaps"

# Delete all files in destination directory
rm "$DEST_DIR"/*

# Create the destination directory if it does not exist
mkdir -p "$DEST_DIR"

# Find all .alloy files in the source directory and copy them to the destination directory
# with their names changed to include their original folder structure, separated by hyphens
find "$SOURCE_DIR" -type f -name "*.alloy" | while read -r file; do
    # Remove the source directory part from the file path
    relative_path="${file#$SOURCE_DIR/}"
    
    # Replace all slashes in the path with hyphens
    new_filename="${relative_path//\//-}"
    
    # Copy the file to the destination directory with the new name
    cp "$file" "$DEST_DIR/$new_filename"
    
    echo "Copied $file to $DEST_DIR/$new_filename"
done

echo "All .alloy files have been copied to $DEST_DIR with their new names."
