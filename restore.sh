#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Step counter
STEP=1
TOTAL_STEPS=10

BACKUP_DIR="$(pwd)/preferences/"
DRY_RUN=false

# ========== Parse args ==========
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
  echo -e "${YELLOW}Dry run enabled: no changes will be made.${NC}"
fi

# ========== Confirm execution ==========
if ! $DRY_RUN; then
  echo -e "${YELLOW}This will restore your system preferences, APT packages, and Brew setup from: ${BACKUP_DIR}${NC}"
  read -rp "Proceed? (y/n): " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || { echo -e "${RED}Aborted.${NC}"; exit 1; }
fi

# ========== Step 1: Update and upgrade Ubuntu ==========
echo -e "${GREEN}[${STEP}/${TOTAL_STEPS}] Updating and upgrading Ubuntu packages...${NC}"
$DRY_RUN || { sudo apt update && sudo apt upgrade -y; }
((STEP++))

# ========== Step 2: Restore APT sources ==========
echo -e "${GREEN}[${STEP}/${TOTAL_STEPS}] Restoring APT sources list...${NC}"
if [[ -f "$BACKUP_DIR/sources.list" || -d "$BACKUP_DIR/sources.list.d" ]]; then
  $DRY_RUN || sudo cp -rv "$BACKUP_DIR"/sources.list* /etc/apt/
  $DRY_RUN || sudo apt update
else
  echo -e "${YELLOW}No sources.list backup found. Skipping.${NC}"
fi
((STEP++))

# ========== Step 3: Restore APT packages ==========
echo -e "${GREEN}[${STEP}/${TOTAL_STEPS}] Reinstalling APT packages...${NC}"
if [[ -f "$BACKUP_DIR/apt-packages.txt" ]]; then
  $DRY_RUN || {
    sudo dpkg --set-selections < "$BACKUP_DIR/apt-packages.txt"
    sudo apt-get dselect-upgrade -y
  }
else
  echo -e "${YELLOW}No APT package list found. Skipping.${NC}"
fi
((STEP++))

# ========== Step 4: Restore manual packages ==========
echo -e "${GREEN}[${STEP}/${TOTAL_STEPS}] Installing manually marked APT packages...${NC}"
if [[ -f "$BACKUP_DIR/manual-packages.txt" ]]; then
  $DRY_RUN || xargs sudo apt-get install -y < "$BACKUP_DIR/manual-packages.txt"
else
  echo -e "${YELLOW}No manual-packages.txt found. Skipping.${NC}"
fi
((STEP++))

# ========== Step 5: Install Homebrew (if needed) ==========
echo -e "${GREEN}[${STEP}/${TOTAL_STEPS}] Checking Homebrew installation...${NC}"
if ! command -v brew &> /dev/null; then
  echo -e "${YELLOW}Homebrew not found. Installing...${NC}"
  $DRY_RUN || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
((STEP++))

# ========== Step 6: Restore Brewfile ==========
echo -e "${GREEN}[${STEP}/${TOTAL_STEPS}] Restoring Brewfile packages...${NC}"
if [[ -f "$BACKUP_DIR/Brewfile" ]]; then
  $DRY_RUN || brew bundle --file="$BACKUP_DIR/Brewfile"
else
  echo -e "${YELLOW}No Brewfile found. Skipping.${NC}"
fi
((STEP++))

# ========== Step 7: Restore Brew services ==========
echo -e "${GREEN}[${STEP}/${TOTAL_STEPS}] Starting Brew services...${NC}"
if [[ -f "$BACKUP_DIR/brew-services.txt" ]]; then
  $DRY_RUN || awk 'NR>1 {print $1}' "$BACKUP_DIR/brew-services.txt" | xargs -r brew services start
else
  echo -e "${YELLOW}No brew-services.txt found. Skipping.${NC}"
fi
((STEP++))

# ========== Step 10: Set up Neovim ==========
echo -e "${GREEN}[${STEP}/${TOTAL_STEPS}] Setting up Neovim...${NC}"
$DRY_RUN || {
  git clone https://github.com/kien5436/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
  cd "${XDG_CONFIG_HOME:-$HOME/.config}/nvim" && git checkout stable
  nvim --headless "+Lazy! sync" +qa
}
((STEP++))

# ========== 4. Install Oh My Zsh and Powerlevel10k ==========
echo -e "${GREEN}[${STEP}/${TOTAL_STEPS}] >_ Setting up Zsh and Oh My Zsh...${NC}"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  $DRY_RUN || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# zsh-autosuggestions
$DRY_RUN || git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

# powerlevel10k
$DRY_RUN || git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

# .zshrc and .p10k.zsh
ZSHRC_URL="https://gist.githubusercontent.com/kien5436/69687913d99cc15ba242f738973b7bff/raw/.zshrc"
P10K_URL="https://gist.githubusercontent.com/kien5436/69687913d99cc15ba242f738973b7bff/raw/.p10k.zsh"
$DRY_RUN || curl -fsSL "$ZSHRC_URL" -o "$HOME/.zshrc"
$DRY_RUN || curl -fsSL "$P10K_URL" -o "$HOME/.p10k.zsh"
((STEP++))

# ========== Step N: Install Docker ==========
if ! command -v docker &>/dev/null; then
  $DRY_RUN || {
    echo -e "${YELLOW}Installing Docker from Docker's official repository...${NC}"
    
    # Prerequisites
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release

    # Add Docker's GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg |
      sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Add Docker repo
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" |
      sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    # Install Docker Engine
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    # Optional: Add user to docker group
    echo -e "${GREEN}[${STEP}/${TOTAL_STEPS}] ????? Adding user to docker group (if not yet)...${NC}"
    if groups "$USER" | grep -q '\bdocker\b'; then
      echo -e "${YELLOW}User already in docker group.${NC}"
    else
      sudo usermod -aG docker "$USER"
    fi
  }

  echo -e "${GREEN}Docker installed successfully.${NC}"
else
  echo -e "${YELLOW}Docker already installed. Skipping.${NC}"
fi
((STEP++))

# ========== Final Note ==========
echo -e "${GREEN}?? All operations completed!${NC}"
echo -e "${YELLOW}?? Note: You may need to log out and back in for Zsh to take effect as your default shell.${NC}"
