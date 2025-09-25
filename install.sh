#!/bin/bash
check_git() {
  if command -v git &> /dev/null; then
    echo " git installed version: $(git --version)"
    return 0
  else
    echo "git not installed"
    return 1
  fi     
}
if ! check_git; then
   echo " please install git"
   exit 1
fi
REPO_URL="https://github.com/veltrix-capital/test-devops-orchestrators.git"
REPO_DIR="test-devops-orchestrators"

# Step 1: Clone or update the repository
if [ -d "$REPO_DIR/.git" ]; then
    echo "[+] Repository exists. Pulling latest changes..."
    cd "$REPO_DIR" && git pull
else
    echo "[+] Cloning repository..."
    git clone "$REPO_URL" "$REPO_DIR"
    cd "$REPO_DIR" || { echo "Failed to enter directory"; exit 1; }
fi

# Step 2: Make scripts executable
echo "[+] Granting execution permissions..."
chmod +x setup.sh start.sh

# Step 3: Run setup.sh
echo "[+] Running setup.sh..."
./setup.sh

echo "Setup is completed"
