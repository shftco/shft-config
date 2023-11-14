#!/bin/bash

if [ "$1" != "FE" ] && [ "$1" != "BE" ] && [ "$1" != "MOBILE" ]; then
  echo "Format must be one of the following: FE, BE, MOBILE"
  exit 1
fi

if ! git rev-parse --is-inside-work-tree > /dev/null; then
  echo "You must run this script inside a git repository"
  exit 1
fi

if [ ! -d .github ]; then
  mkdir .github
fi

cd .github

if [ -f pull_request_template.md ]; then
  echo "pull_request_template.md already exists"
else
  if [ "$1" == "FE" ]; then
    curl -o pull_request_template.md https://raw.githubusercontent.com/shftco/shft-git-config/main/pullmate/FE/pull_request_template.md
  elif [ "$1" == "BE" ]; then
    curl -o pull_request_template.md https://raw.githubusercontent.com/shftco/shft-git-config/main/pullmate/BE/pull_request_template.md
  elif [ "$1" == "MOBILE" ]; then
    curl -o pull_request_template.md https://raw.githubusercontent.com/shftco/shft-git-config/main/pullmate/MOBILE/pull_request_template.md
  fi
fi

if [ ! -d workflows ]; then
  mkdir workflows
fi

cd workflows

if [ -f shft-pullmate.yml ]; then
  echo "shft-pullmate.yml"
else
  curl -o shft-pullmate.yml https://raw.githubusercontent.com/shftco/shft-git-config/main/pullmate/shft-pullmate.yml
  echo "shft-pullmate.yml created. Please check the latest version of the shft-pullmate from Github Marketplace and update the file."
fi

cd ../..
