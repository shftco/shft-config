#!/bin/bash

if [ "$(uname)" != "Darwin" ]; then
  echo "This script is only for mac"
  exit 1
fi

if [ -z "$1" ]; then
  echo "Github username is required. Please provide your github username as the first argument"
  exit 1
fi

if [ -z "$2" ]; then
  echo "Github email is required. Please provide your github email as the second argument"
  exit 1
fi

if ! which brew > /dev/null; then
  echo "You must install homebrew"
  exit 1
fi

if ! which curl > /dev/null; then
  echo "You must install curl"
  exit 1
fi

if ! git --version > /dev/null; then
  echo "Git is not installed yet. Installing git..."
  brew install git

  xcode-select --install
fi

git config --global color.ui true
git config --global user.name "$1"
git config --global user.email "$2"
ssh-keygen -t ed25519 -C "$2"

echo "Your public key is:"
cat ~/.ssh/id_ed25519.pub
echo "Please add this key to your github account"
