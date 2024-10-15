#!/bin/bash

export PAGER=cat
export GH_PAGER=cat

REPO_NAME=$1
repo_type=$2
flag=$3

OWNER="shftco"

if [ -z "$REPO_NAME" ]; then
  echo "Usage: $0 <repo_name> <repo_type> <flag (optional)>"
  exit 1
fi

if [ -z "$repo_type" ]; then
  echo "Usage: $0 $REPO_NAME <repo_type> <flag (optional)>"
  exit 1
fi

available_repo_types=("backend" "frontend" "mobile")

if [[ ! " ${available_repo_types[@]} " =~ " ${repo_type} " ]]; then
  echo "Invalid repo type. Available repo types: ${available_repo_types[@]}"
  exit 1
fi

available_flags=("all" "ask")

if [ -z "$flag" ]; then
  flag="ask"
fi

if [[ ! " ${available_flags[@]} " =~ " ${flag} " ]]; then
  echo "Invalid flag. Available flags: ${available_flags[@]}"
  exit 1
fi

function git_installed() {
  command -v git >/dev/null 2>&1
}

function inside_git_repo() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

function has_any_commits() {
  git log --oneline -1 >/dev/null 2>&1
}

function gh_cli_installed() {
  command -v gh >/dev/null 2>&1
}

function gh_cli_logined() {
  gh auth status --show-token >/dev/null 2>&1
}

function install_husky() {  
  if [ -d ".husky" ]; then
    echo "Husky is already installed. (Skipping)"
    return
  fi

  bash <(curl -s https://raw.githubusercontent.com/shftco/shft-git-config/main/husky/script.sh)
}

function install_changelog_generator() {
  if [ -f "cliff.toml" ]; then
    echo "Changelog generator is already installed. (Skipping)"
    return
  fi

  bash <(curl -s https://raw.githubusercontent.com/shftco/shft-git-config/main/changelog/script.sh)
}

function install_git_release_script() {
  if [ -f "scripts/release.sh" ]; then
    echo "Git release script is already installed. (Skipping)"
    return
  fi

  mkdir -p scripts
  curl -o scripts/release.sh https://raw.githubusercontent.com/shftco/shft-git-config/main/release/script.sh
  chmod +x scripts/release.sh

  if [ "$repo_type" == "backend" ]; then
    touch Makefile
    content=".PHONY: release\nrelease:\n\tchmod +x ./scripts/release.sh && ./scripts/release.sh"
    echo -e $content > Makefile
  else
    npm pkg set scripts.release="chmod +x ./scripts/release.sh && ./scripts/release.sh"
  fi
}

function install_shft_pullmate() {
  if [ -f ".github/workflows/shft-pullmate.yml" ]; then
    echo "Shft pullmate is already installed. (Skipping)"
    return
  fi

  if [ "$repo_type" == "backend" ]; then
    bash <(curl -s https://raw.githubusercontent.com/shftco/shft-git-config/main/pullmate/script.sh) BE
  elif [ "$repo_type" == "frontend" ]; then
    bash <(curl -s https://raw.githubusercontent.com/shftco/shft-git-config/main/pullmate/script.sh) FE
  elif [ "$repo_type" == "mobile" ]; then
    bash <(curl -s https://raw.githubusercontent.com/shftco/shft-git-config/main/pullmate/script.sh) MOBILE
  fi
}

function install_codeowners() {
  if [ -f "CODEOWNERS" ]; then
    echo "Codeowners is already installed. (Skipping)"
    return
  fi

  echo "* @sonergonencler @nejdetkadir" > CODEOWNERS
}

function setup_default_repository_settings() {
  gh api -X PATCH \
  -H "Accept: application/vnd.github.v3+json" \
  "/repos/$OWNER/$REPO_NAME" \
  -f allow_merge_commit=false \
  -f allow_squash_merge=true \
  -f allow_rebase_merge=false \
  -f squash_merge_commit_title="PR_TITLE" \
  -f delete_branch_on_merge=true \
  -f allow_forking=false
}

function setup_branch_protection_rules() {
  if ! has_any_commits; then
    if ask_yes_or_no_question "There are no commits in the repository. Do you want to create a commit and push it to the repository?"; then
      git add .
      git commit -m "chore: initial commit" --no-verify
      current_branch=$(git branch --show-current)
      git remote add origin git@github.com:$OWNER/$REPO_NAME.git
      git push origin $current_branch
    else
      echo "Please create a commit and push it to the repository before setting up branch protection rules."
      exit 1
    fi 
  fi

  mkdir -p ~/.shft-assistant
  curl -o ~/.shft-assistant/branch_protection.json https://raw.githubusercontent.com/shftco/shft-git-config/main/assistant/branch_protection.json

  gh api -X PUT \
  -H "Accept: application/vnd.github.v3+json" \
  "/repos/$OWNER/$REPO_NAME/branches/main/protection" \
  --input ~/.shft-assistant/branch_protection.json
}

function setup_github_action_templates() {
  echo "Setting up GitHub action templates not implemented yet."
}


# Installing scripts #


function ask_yes_or_no_question() {
  question=$1
  read -p "$question (y/n): " -n 1 -r
  echo ""

  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    return 1
  fi

  return 0
}

if ! git_installed; then
  echo "Git is not installed. Please install git before running this script."
  exit 1
fi

if ! inside_git_repo; then
  if ask_yes_or_no_question "This is not a git repository. Do you want to initialize a git repository?"; then
    git init .
  else
    echo "Please run this script inside a git repository."
    exit 1
  fi
fi

if ! gh_cli_installed; then
  echo "GitHub CLI is not installed. Please install it from https://cli.github.com"
  exit 1
fi

if ! gh_cli_logined; then
  echo "You are not logged in to GitHub CLI. Please login using 'gh auth login'"
  exit 1
fi

if [ "$flag" == "ask" ]; then
  if ask_yes_or_no_question "Do you want to install husky?"; then
    install_husky
  fi

  if ask_yes_or_no_question "Do you want to install changelog generator?"; then
    install_changelog_generator
  fi

  if ask_yes_or_no_question "Do you want to install git release script?"; then
    install_git_release_script
  fi

  if ask_yes_or_no_question "Do you want to install shft pullmate?"; then
    install_shft_pullmate
  fi

  if ask_yes_or_no_question "Do you want to install codeowners?"; then
    install_codeowners
  fi

  if ask_yes_or_no_question "Do you want to setup default repository settings?"; then
    setup_default_repository_settings
  fi

  if ask_yes_or_no_question "Do you want to setup GitHub action templates?"; then
    setup_github_action_templates
  fi

  if ask_yes_or_no_question "Do you want to setup branch protection rules?"; then
    setup_branch_protection_rules
  fi
else
  install_husky
  install_changelog_generator
  install_git_release_script
  install_shft_pullmate
  install_codeowners
  setup_default_repository_settings
  setup_github_action_templates
  setup_branch_protection_rules
fi
