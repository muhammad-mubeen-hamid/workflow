#!/bin/bash
set -e

# Ensure required environment variables are set
if [[ -z "$SVN_USERNAME" || -z "$SVN_PASSWORD" || -z "$SVN_REPO_URL" ]]; then
  echo "Error: SVN credentials or repository URL not set. Exiting."
  exit 1
fi

# Install SVN if not already installed
if ! command -v svn &> /dev/null; then
  echo "Installing SVN..."
  sudo apt-get update
  sudo apt-get install -y subversion
fi

# Checkout SVN repository
echo "Checking out SVN repository..."
svn checkout --username "$SVN_USERNAME" --password "$SVN_PASSWORD" "$SVN_REPO_URL" svn-repo

# Sync Git content to SVN repository
echo "Syncing files to SVN repository..."
rsync -av --delete ./trunk/ svn-repo/trunk/
rsync -av --delete ./assets/ svn-repo/assets/
rsync -av --delete ./tags/ svn-repo/tags/

# Add new files to SVN
echo "Adding new files to SVN..."
cd svn-repo
svn add --force * --auto-props --parents --depth infinity -q

# Commit changes to SVN
echo "Committing changes to SVN..."
svn commit -m "Deploying from git commit $GITHUB_SHA" --username "$SVN_USERNAME" --password "$SVN_PASSWORD" --no-auth-cache --non-interactive
