#!/bin/bash

echo "# Modules"
echo ""

# Function to check if directory (or its subdirectories) contains .md files
contains_md_files() {
  local dir="$1"
  if find "$dir" -type f -name "*.md" | read -r; then
    return 0 # True, contains .md files
  else
    return 1 # False, does not contain .md files
  fi
}

# Function to generate nested markdown list
generate_list() {
  local parent_path="$1"
  local indent="$2"
  # List directories first
  for dir in $(find "$parent_path" -mindepth 1 -maxdepth 1 -type d | sort); do
    if contains_md_files "$dir"; then
      local dir_name
      dir_name=$(basename "$dir")
      echo "${indent}-   [${dir_name}](${dir}/)"
      # Check and list subdirectories if they contain .md files
      if [ "$(find "$dir" -mindepth 1 -maxdepth 1 -type d)" ]; then
        generate_list "$dir" "$indent    "
      fi
    fi
  done
}

# Start from the top-level "modules" directory
generate_list "modules" ""
