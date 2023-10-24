#!/bin/bash

if ! git rev-parse --is-inside-work-tree > /dev/null; then
  echo "You must run this script inside a git repository"
  exit 1
fi

if ! which husky > /dev/null; then
  npm install --global husky
fi

if [ ! -f .husky/pre-push ]; then
  curl -o .husky/pre-push https://raw.githubusercontent.com/shftco/shft-git-config/main/husky/pre-push
fi

if [ ! -f .husky/commit-msg ]; then
  curl -o .husky/commit-msg https://raw.githubusercontent.com/shftco/shft-git-config/main/husky/commit-msg
fi

if [ ! -f .commitlintrc.js ]; then
  curl -o .commitlintrc.js https://raw.githubusercontent.com/shftco/shft-git-config/main/husky/.commitlintrc.js
fi

if [ -f package.json ]; then
  if [ -f yarn.lock ]; then
    yarn add -D @commitlint/{config-conventional,cli} husky
  else
    npm install --save-dev @commitlint/{config-conventional,cli} husky
  fi

  npm pkg set scripts.prepare="husky install"
fi

npx husky install
