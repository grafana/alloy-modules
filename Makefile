.DEFAULT_GOAL:= lint
PATH := ./node_modules/.bin:$(PATH)
SHELL := /bin/bash
args = $(filter-out $@, $(MAKECMDGOALS))
.PHONY: all setup install clean reinstall lint lint-sh lint-shell lint-md lint-markdown lint-txt lint-text lint-yaml lint-yml lint-editorconfig lint-ec lint-alex lint-misspell lint-actionlint lint-river

default: all

all: install

####################################################################
#                   Installation / Setup                           #
####################################################################
setup:
	@./tools/setup.sh

install:
	yarn install

# remove the build and log folders
clean:
	rm -rf node_modules

# reinstall the node_modules and start with a fresh node build
reinstall: clean install

####################################################################
#                           Linting                                #
####################################################################
lint: lint-shell lint-markdown lint-text lint-yaml lint-editorconfig lint-alex lint-misspell lint-actionlint lint-river

# Note "|| true" is added to locally make lint can be ran and all linting is preformmed, regardless of exit code

# Shell Linting
lint-sh lint-shell:
	@./tools/lint-shell.sh || true

# Markdown Linting
lint-md lint-markdown:
	@./tools/lint-markdown.sh || true

# Text Linting
lint-txt lint-text:
	@./tools/lint-text.sh || true

# Yaml Linting
lint-yml lint-yaml:
	@./tools/lint-yaml.sh || true

# Editorconfig Linting
lint-ec lint-editorconfig:
	@./tools/lint-editorconfig.sh || true

# Alex Linting
lint-alex:
	@./tools/lint-alex.sh || true

# Misspell Linting
lint-misspell:
	@./tools/lint-misspell.sh || true

# Actionlint Linting
lint-actionlint:
	@./tools/lint-actionlint.sh || true

# River Linting
lint-river:
	@./tools/lint-river.sh || true
