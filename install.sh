#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define color codes
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Define repository URLs
REPO_YASLI="https://github.com/agronskiy/yasli.git"
REPO_DOTFILES="https://github.com/agronskiy/dotfiles-small.git"

# Clone Repo A into ~/.yasli
echo -e "${YELLOW}Cloning yasli into ~/.yasli...${NC}"
if git clone "$REPO_YASLI" ~/.yasli; then
    echo -e "${GREEN}OK: Cloned successfully.${NC}"
else
    echo -e "${RED}FAIL: Failed to clone yasli.${NC}"
    exit 1
fi

# Clone Repo B into ~/.dotfiles-small
echo -e "${YELLOW}Cloning dotfiles into ~/.dotfiles-small...${NC}"
if git clone "$REPO_DOTFILES" ~/.dotfiles-small; then
    echo -e "${GREEN}OK: Cloned successfully.${NC}"
else
    echo -e "${RED}FAIL: Failed to clone dotfiles.${NC}"
    exit 1
fi

# Binaries will be installed into this directory
export PATH=$HOME/.local/bin:$PATH

# Run the command with DOTFILES pointing to the cloned Repo B directory
echo -e "${YELLOW}Running yasli-main script...${NC}"
if DOTFILES=~/.dotfiles-small ~/.yasli/yasli-main; then
    echo -e "${GREEN}OK: Script executed successfully.${NC}"
else
    echo -e "${RED}FAIL: Script execution failed.${NC}"
    exit 1
fi

echo -e "${GREEN}Script execution completed successfully.${NC}"

# Define the snippet to be added
SNIPPET_MARKER="# >>> added by .dotfiles-small installer"
SNIPPET="$SNIPPET_MARKER
if [ -f ~/.bashrc-custom ]; then
    . ~/.bashrc-custom
fi
# <<< end"

# Prompt the user
echo "Adding \n$SNIPPET\nto ~/.bashrc (if not existing)"
echo -e "\n$SNIPPET\n"
read -p "Your choice: " choice

# Check if the snippet is already in .bashrc
if grep -Fxq "$SNIPPET_MARKER" ~/.bashrc; then
    echo -e "${YELLOW}The snippet is already present in your .bashrc. No changes made.${NC}"
else
    # Append the snippet to .bashrc
    echo -e "\n# Load custom bash configurations\n$SNIPPET" >> ~/.bashrc
    echo -e "${GREEN}Snippet added successfully to your .bashrc.${NC}"
fi
