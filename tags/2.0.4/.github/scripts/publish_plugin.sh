#!/bin/bash
set -e

# Install SVN
sudo apt-get update
sudo apt-get install -y subversion

# Checkout SVN Repository
svn checkout --username "${SVN_USERNAME}" --password "${SVN_PASSWORD}" hhttps://svn.riouxsvn.com/melowing svn-repo

# Create Tag Directory in SVN
svn mkdir svn-repo/tags/${VERSION} -m "Create SVN tag ${VERSION}"

# Sync Files to SVN Tag
rsync -av --delete ./trunk/ svn-repo/tags/${VERSION}/

# Add and Commit Changes to SVN
cd svn-repo/tags/${VERSION}
svn add --force * --auto-props --parents --depth infinity -q
svn commit -m "Deploy version ${VERSION} from Git commit ${GITHUB_SHA}" --username "${SVN_USERNAME}" --password "${SVN_PASSWORD}" --no-auth-cache --non-interactive
