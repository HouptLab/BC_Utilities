#!/bin/bash

#  Markdown-BuildRule.sh
#
#  Created by Chuck Houpt on the sixth day of the year of the Horse.
#  Copyright (c) 2014 Behavioral Cybernetics. All rights reserved.

# Setup

# This is an XCode Build Rule Script, so it needs to be called from a Build Rule to function.
#
# 1. Create a custom Build Rule. See:
# https://developer.apple.com/library/ios/recipes/xcode_help-project_editor/Articles/Adding%20a%20Build%20Rule.html
#
# 2. Setup new Build Rule with the following settings:
#		Title: Compile Markdown Files '*.md' with Markdown-BuildRule Script
#		Process: Source files with names matching: *.md
#		Script: ./Markdown-BuildRule.sh
#		Output File: $(DERIVED_FILE_DIR)/$(INPUT_FILE_BASE).html

# Usage

# All *.md files (that are Target members) are converted to HTML and copied to the target's Resources folder.
#
# The HTML will be themed if .theme files are found. A theme file can either:
#	- The generic 'pages.theme' for all files in a directory tree.
#   - A page specific theme file, with the same base-name.
#
# (See 'theme' command man page for details of meta-markup, etc)
#
# Examples of a page-specific theme file:
#		example.md
#		example.theme - theme only applied to example.md to create example.html
#
# Example of a theme applied to all pages in directory:
#		doc/a.md
#		doc/b.md
#		doc/c.md
#		doc/pages.theme - theme applied to all

set -eux

# Add local tools to path, since XCode doesn't include them by default.
PATH=$PATH:/usr/local/bin

# Check for Discount tools
if ! which theme
then
	echo "error: Discount's theme command not found. To install Discount with Homebrew, run 'brew install discount'"
fi

theme -t "${INPUT_FILE_DIR}/${INPUT_FILE_BASE}.theme" -o "${DERIVED_FILE_DIR}/${INPUT_FILE_BASE}.html" "${INPUT_FILE_PATH}"

# For debugging:
#open "${DERIVED_FILE_DIR}/${INPUT_FILE_BASE}.html"