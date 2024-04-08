#!/usr/bin/env bash

source "$(pwd)/tools/includes/utils.sh"

source "./tools/includes/logging.sh"

# output the heading
heading "Agent" "Modules - Performing Setup Checks"

# make sure Node exists
info "Checking to see if Node is installed"
if [[ "$(command -v node)" = "" ]]; then
  warning "node is required if running lint locally, see: (https://nodejs.org) or run: brew install nvm && nvm install 18";
else
  success "node is installed"
fi

# make sure yarn exists
info "Checking to see if yarn is installed"
if [[ "$(command -v yarn)" = "" ]]; then
  warning "yarn is required if running lint locally, see: (https://yarnpkg.com) or run: brew install yarn";
else
  success "yarn is installed"
fi

# make sure shellcheck exists
info "Checking to see if shellcheck is installed"
if [[ "$(command -v shellcheck)" = "" ]]; then
  warning "shellcheck is required if running lint locally, see: (https://shellcheck.net) or run: brew install nvm && nvm install 18";
else
  success "shellcheck is installed"
fi

# make sure misspell exists
info "Checking to see if misspell is installed"
if [[ "$(command -v misspell)" = "" ]]; then
  warning "misspell is required if running lint locally, see: (https://github.com/client9/misspell) or run: go install github.com/client9/misspell/cmd/misspell@latest";
else
  success "misspell is installed"
fi

# make sure misspell exists
info "Checking to see if actionlint is installed"
if [[ "$(command -v misspell)" = "" ]]; then
  warning "actionlint is required if running lint locally, see: (https://github.com/rhysd/actionlint) or run: go install github.com/rhysd/actionlint/cmd/actionlint@latest";
else
  success "actionlint is installed"
fi

# make sure grafana-agent exists
info "Checking to see if grafana-agent is installed"
if [[ "$(command -v grafana-agent)" = "" ]]; then
  warning "grafana-agent is required if running lint locally, see: (https://grafana.com/docs/agent/latest/) or run: brew install grafana-agent";
else
  success "grafana-agent is installed"
fi
