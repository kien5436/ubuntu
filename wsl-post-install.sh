#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Step counter
STEP=1
TOTAL_STEPS=9

# Update and upgrade Ubuntu packages
echo -e "${GREEN}[${STEP}/${TOTAL_STEPS}] Updating and upgrading Ubuntu packages...${NC}"
sudo apt update && sudo apt upgrade -y
((STEP++))

# Install prerequisites for Homebrew
echo -e "${GREEN}[${STEP}/${TOTAL_STEPS}] Installing prerequisites for Homebrew...${NC}"
sudo apt install -y build-essential procps file ca-certificates gnupg
((STEP++))

# Install Homebrew
if command -v brew &>/dev/null; then
  echo -e "${YELLOW}[${STEP}/${TOTAL_STEPS}] Homebrew already installed - skipping${NC}"
else
  echo -e "${GREEN}[${STEP}/${TOTAL_STEPS}] Installing Homebrew...${NC}"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Add Homebrew to PATH
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  brew analytics off
fi
((STEP++))

# Verify Homebrew
brew --version || { echo -e "${RED}Homebrew verification failed${NC}"; exit 1; }

# Install Zsh
if command -v zsh &>/dev/null; then
  echo -e "${YELLOW}[${STEP}/${TOTAL_STEPS}] Zsh already installed - skipping${NC}"
else
  echo -e "${GREEN}[${STEP}/${TOTAL_STEPS}] Installing Zsh...${NC}"
  brew install zsh
fi
((STEP++))

# Set Zsh as default shell
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
  echo -e "${GREEN}[${STEP}/${TOTAL_STEPS}] Setting Zsh as default shell...${NC}"
  # WARNING: this is a temporary fix should be applied for WSL with ONE account only.
  # Brew install packages for local user so others might encounter error when login because zsh isn't available in their environment
  echo '/home/linuxbrew/.linuxbrew/bin/zsh' >> /etc/shells
  chsh -s $(which zsh)
else
  echo -e "${YELLOW}[${STEP}/${TOTAL_STEPS}] Zsh is already the default shell - skipping${NC}"
fi
((STEP++))

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo -e "${GREEN}[${STEP}/${TOTAL_STEPS}] Installing Oh My Zsh...${NC}"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  ZSHRC_PATH="$HOME/.zshrc"
  ZSHRC_BACKUP_PATH="$HOME/.zshrc.backup"
  ZSHRC_GIST_URL="https://gist.githubusercontent.com/kien5436/69687913d99cc15ba242f738973b7bff/raw/43698e1fff4b2ba2d8bb2282331c4dd8e778e7df/.zshrc"

  # Backup existing .zshrc if it exists
  if [ -f "$ZSHRC_PATH" ]; then
    echo -e "${YELLOW}Backing up existing .zshrc to $ZSHRC_BACKUP_PATH...${NC}"
    cp "$ZSHRC_PATH" "$ZSHRC_BACKUP_PATH"
  fi
  
  # Download and replace .zshrc
  echo -e "${GREEN}Downloading new .zshrc configuration...${NC}"
  if curl -sSL "$ZSHRC_GIST_URL" -o "$ZSHRC_PATH"; then
    echo -e "${GREEN}Successfully updated .zshrc!${NC}"
    
    # Source the new configuration
    echo -e "${YELLOW}Sourcing the new .zshrc file...${NC}"
    source "$ZSHRC_PATH"
  else
    echo -e "${RED}Failed to download the .zshrc file${NC}"
    
    # Restore backup if download failed
    if [ -f "$ZSHRC_BACKUP_PATH" ]; then
      echo -e "${YELLOW}Restoring original .zshrc from backup...${NC}"
      mv "$ZSHRC_BACKUP_PATH" "$ZSHRC_PATH"
    fi
  fi

else
  echo -e "${YELLOW}[${STEP}/${TOTAL_STEPS}] Oh My Zsh already installed - skipping${NC}"
fi
((STEP++))

# Install other packages using Homebrew
echo -e "${GREEN}[${STEP}/${TOTAL_STEPS}] Installing packages with Homebrew...${NC}"
sudo apt purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo rm /etc/apt/sources.list.d/docker.list
sudo rm /etc/apt/keyrings/docker.asc
sudo apt autoremove -y
brew install node pnpm neovim docker rust gcc ripgrep
((STEP++))

# Verification and completion
echo -e "\n${GREEN}Verifying installations:${NC}"

# Node.js - use node with --version but also check npm to be thorough
command -v node >/dev/null && node --version || echo -e "${RED}Node.js installation failed${NC}"

# pnpm - check both the command and version
command -v pnpm >/dev/null && pnpm --version || echo -e "${RED}pnpm installation failed${NC}"

# Neovim - check executable and version
command -v nvim >/dev/null && nvim --version | head -n 1 || echo -e "${RED}Neovim installation failed${NC}"

# Docker - check if docker command exists and can run
command -v docker >/dev/null && docker --version || echo -e "${RED}Docker installation failed${NC}"

# Rust - check both rustc and cargo
command -v rustc >/dev/null && rustc --version || echo -e "${RED}Rust installation failed${NC}"
command -v cargo >/dev/null || echo -e "${RED}Rust cargo not found${NC}"

# GCC verification (specific to Homebrew installation)
if brew list gcc &>/dev/null; then
  echo -e "GCC $(gcc-$(brew list --versions gcc | cut -d' ' -f2 | cut -d. -f1) --version | head -n 1) ${GREEN}(installed via Homebrew)${NC}"
else
  echo -e "${RED}GCC installation via Homebrew failed${NC}"
fi

echo -e "${GREEN}[${STEP}/${TOTAL_STEPS}] Installing nerd font for neovim...${NC}"

brew install --cask font-noto-color-emoji

# Font information
FONT_NAME="FiraCode Nerd Font"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip"
FONT_ZIP="FiraCode.zip"
FONT_DIR="$HOME/.local/share/fonts"

# Check if font is already installed
if fc-list | grep -i "Fira Code" >/dev/null; then
  echo -e "${YELLOW}$FONT_NAME is already installed.${NC}"
  exit 0
fi

# Create fonts directory if it doesn't exist
echo -e "${GREEN}Creating fonts directory...${NC}"
mkdir -p "$FONT_DIR"

# Download the font
echo -e "${GREEN}Downloading $FONT_NAME...${NC}"
if ! wget -q "$FONT_URL" -O "$FONT_ZIP"; then
  echo -e "${RED}Failed to download $FONT_NAME.${NC}"
  exit 1
fi

# Extract the font
echo -e "${GREEN}Extracting $FONT_NAME...${NC}"
unzip -q -o "$FONT_ZIP" -d "$FONT_DIR/"

# Clean up
echo -e "${GREEN}Cleaning up...${NC}"
rm "$FONT_ZIP"

# Update font cache
echo -e "${GREEN}Updating font cache...${NC}"
fc-cache -fv

# Verify installation
if fc-list | grep -i "FiraCode" >/dev/null; then
  echo -e "${GREEN}$FONT_NAME installed successfully!${NC}"
else
  echo -e "${RED}Font installation failed.${NC}"
  exit 1
fi
((STEP++))

echo -e "${GREEN}[${STEP}/${TOTAL_STEPS}] Setting up neovim...${NC}"

git clone https://github.com/kien5436/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
cd "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim && git checkout stable

echo -e "\n${GREEN}All operations completed!${NC}"
echo -e "${YELLOW}Note: You may need to log out and back in for Zsh to take effect as your default shell.${NC}"
