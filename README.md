# Development Environment Version Checker

A bash script that lists versions of all development tools and offers to update them.

## Features

- Lists versions of all development tools
- Offers to update tools with user confirmation  
- Auto-detects common development tools

## How to Clone

git clone git@github.com:yashwandhare/version-check.git
cd version-check
cp version-check.sh ~/bin/version-check
chmod +x ~/bin/version-check
echo 'alias version-check="~/bin/version-check"' >> ~/.zshrc
source ~/.zshrc

## Dependencies

These will be installed automatically:
sudo apt update
sudo apt install curl jq pipx -

## How to Use
version-check
Then select 'y' when prompted to check for updates.


