#!/bin/bash
set -e

# Define the path to the readme file
README_PATH="trunk/readme.md"

# Check if the readme file exists
if [ ! -f "$README_PATH" ]; then
  echo "Error: Readme file not found at $README_PATH. Exiting."
  exit 1
fi

# Extract the version number from the readme file
VERSION_LINE=$(grep -i "^Version:" "$README_PATH" || true)

if [[ "$VERSION_LINE" =~ ^Version:\ ([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
  VERSION="${BASH_REMATCH[1]}"
  echo "Extracted version: $VERSION"
else
  echo "Error: No valid version number found in the readme file. Exiting."
  exit 1
fi

# Ensure tags directory exists
if [ ! -d "tags" ]; then
  echo "Creating 'tags/' directory."
  mkdir tags
fi

# Check if the tag already exists
if [ -d "tags/$VERSION" ]; then
  echo "Tag folder tags/$VERSION already exists. Exiting."
  exit 1
else
  echo "Creating tag folder tags/$VERSION."
  mkdir -p tags/$VERSION
  rsync -av --exclude='tags' --exclude='.git' --exclude='.github' ./ tags/$VERSION/
fi

# Commit the new tag to the Git repository
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git add tags/$VERSION/
git commit -m "Create tag folder v$VERSION from commit $GITHUB_SHA"
git push origin master
