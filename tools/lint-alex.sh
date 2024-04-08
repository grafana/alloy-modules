#!/usr/bin/env bash

source "$(pwd)/tools/includes/utils.sh"

source "./tools/includes/logging.sh"

# output the heading
heading "Agent" "Modules - Performing Text Linting using alex"

# check to see if remark is installed
if [[ ! -f "$(pwd)"/node_modules/.bin/textlint ]]; then
  emergency "alex node module is not installed, please run: make install";
fi

# determine whether or not the script is called directly or sourced
(return 0 2>/dev/null) && sourced=1 || sourced=0

statusCode=0
"$(pwd)"/node_modules/.bin/alex --config "$(pwd)/.textlintrc" "$(pwd)/guides/"*.md "$(pwd)/guides/"**/*.md
currentCode="$?"
# only override the statusCode if it is 0
if [[ "$statusCode" == 0 ]]; then
  statusCode="$currentCode"
fi

if [[ "$statusCode" == "0" ]]; then
  echo "no issues found"
  echo ""
fi

echo ""

# if the script was called by another, send a valid exit code
if [[ "$sourced" == "1" ]]; then
  return "$statusCode"
else
  exit "$statusCode"
fi
