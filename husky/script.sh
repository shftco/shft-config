#!/bin/bash

function check_husy_hooks {
  if [ ! -f pre-push ]; then
    curl -o pre-push https://raw.githubusercontent.com/shftco/shft-git-config/main/husky/pre-push
    chmod +x pre-push
  fi

  if [ ! -f commit-msg ]; then
    curl -o commit-msg https://raw.githubusercontent.com/shftco/shft-git-config/main/husky/commit-msg
    chmod +x commit-msg
  fi
}

if ! git rev-parse --is-inside-work-tree > /dev/null; then
  echo "You must run this script inside a git repository"
  exit 1
fi

if ! which husky > /dev/null; then
  npm install --global husky
fi

if [ ! -d .husky ]; then
  mkdir .husky
  cd .husky
  check_husy_hooks
else
  cd .husky
  check_husy_hooks
fi

cd ..

if [ ! -f .commitlintrc.json ]; then
  curl -o .commitlintrc.json https://raw.githubusercontent.com/shftco/shft-git-config/main/husky/.commitlintrc.json
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
