#!/bin/bash
set -e

# Extract Version Number
COMMIT_MESSAGE=$(git log -1 --pretty=%B)
echo "Commit message: $COMMIT_MESSAGE"

if [[ "$COMMIT_MESSAGE" =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
  VERSION="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}"
  echo "VERSION=$VERSION" >> $GITHUB_ENV
  echo "Extracted version: $VERSION"
else
  echo "Commit message does not match 'vX.X.X' pattern."
  exit 1
fi

# Check if Tag Exists
if [ -d "tags/${VERSION}" ]; then
  echo "Tag folder tags/${VERSION} already exists."
  exit 1
else
  echo "Creating tag folder tags/${VERSION}."
fi

# Create Tag Folder and Copy Files
mkdir -p tags/${VERSION}
rsync -av --exclude='tags' --exclude='.git' ./ tags/${VERSION}/
rm -rf tags/${VERSION}/.github  # Optional: Remove workflow files
ls -R tags/${VERSION}/

# Configure Git
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

# Commit and Push Tag Folder
git add tags/${VERSION}/
git commit -m "Create tag folder v${VERSION} from commit ${GITHUB_SHA}"
git push origin ${GITHUB_SHA}
