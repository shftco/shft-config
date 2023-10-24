#!/bin/bash

if ! git rev-parse --is-inside-work-tree > /dev/null; then
  echo "You must run this script inside a git repository"
  exit 1
fi

if ! which brew > /dev/null; then
  echo "You must install homebrew"
fi

if ! which git-conventional-commits > /dev/null; then
  npm install --global git-conventional-commits
fi

if ! which pre-commit > /dev/null; then
  brew install pre-commit
fi

pre-commit install -t commit-msg

if [ ! -f .pre-commit-config.yaml ]; then
  curl -o .pre-commit-config.yaml <url>
fi

if [ ! -f git-conventional-commits.yaml ]; then
  curl -o git-conventional-commits.yaml <url>
fi

if [ -f package.json ]; then
  if [ -f yarn.lock ]; then
    yarn add -D git-conventional-commits
  else
    npm install --save-dev git-conventional-commits
  fi
fi
