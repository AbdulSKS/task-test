#!/bin/bash



echo "[Swap Optimizer Setup] Starting setup..."

# Detect OS and install Node.js if missing
OS="$(uname -s)"

detect_and_install_node() {
    if command -v node &>/dev/null && command -v npm &>/dev/null; then
        echo "[INFO] Node.js already installed: $(node -v)"
        echo "[INFO] npm version: $(npm -v)"
        return
    fi

    echo "[INFO] Node.js or npm not found. Attempting installation..."

    case "$OS" in
        Linux*)
            if [ -f /etc/debian_version ]; then
                echo "[INFO] Installing Node.js via apt..."
                curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
                sudo apt install -y nodejs
            elif [ -f /etc/redhat-release ]; then
                echo "[INFO] Installing Node.js via yum..."
                curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
                sudo yum install -y nodejs
            else
                echo "[WARN] Unsupported Linux distro. Please install Node.js manually."
                exit 1
            fi
            ;;
        Darwin*)
            if command -v brew &>/dev/null; then
                echo "[INFO] Installing Node.js via Homebrew..."
                brew install node
            else
                echo "[ERROR] Homebrew not found. Please install Node.js manually."
                exit 1
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*)
            echo "[INFO] Detected Windows (Git Bash or WSL). Please install Node.js manually from https://nodejs.org/"
            exit 1
            ;;
        *)
            echo "[ERROR] Unknown OS: $OS"
            exit 1
            ;;
    esac
}

detect_and_install_node

NODE_MAJOR=$(node -v | sed 's/v\([0-9]*\).*/\1/')
if [ "$NODE_MAJOR" -lt 18 ]; then
    echo "[ERROR] Node.js version 18 or higher is required. Found: $(node -v)"
    exit 1
fi


# Prepare logs directory
mkdir -p logs
SETUP_LOG="logs/setup_$(date +%Y%m%d_%H%M%S).log"
RUN_LOG="logs/run_$(date +%Y%m%d_%H%M%S).log"

exec > >(tee -a "$SETUP_LOG") 2>&1

# Install dependencies
echo "[INFO] Installing Node.js dependencies..."
npm install

# Prepare .env file
if [ ! -f .env ]; then
    if [ -f .env_example ]; then
        cp .env_example .env
        echo "[INFO] Copied .env_example to .env"
        echo "[WARN] Update your INFURA_URL in .env before proceeding."
    else
        echo "[ERROR] No .env or [].env_example found. Cannot continue."
        exit 1
    fi
fi

echo "[Swap Optimizer Setup] Setup complete."
echo "[INFO] Setup logs saved to: $SETUP_LOG"
echo "[INFO] Runtime logs will be saved to: $RUN_LOG"
echo "[INFO] Starting dev server..."

npm run dev > >(tee -a "$RUN_LOG") 2>&1


