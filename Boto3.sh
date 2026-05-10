#!/bin/bash

LOG_FILE="$HOME/Library/Logs/boto3_install.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "===== boto3 Installation Script Started ====="
echo "Date: $(date)"
echo "User: $(whoami)"
echo "Home: $HOME"

# Check python3
if ! command -v python3 &> /dev/null; then
    echo "ERROR: python3 not found! Please install Python 3 manually."
    exit 1
else
    echo "Found python3: $(python3 --version)"
fi

# Check pip3
if ! command -v pip3 &> /dev/null; then
    echo "pip3 not found. Installing pip3 via get-pip.py..."

    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python3 get-pip.py --user
    rm get-pip.py

    # Add user's local bin to PATH for current session
    export PATH=$HOME/Library/Python/$(python3 -c "import sys; print('{}.{}'.format(sys.version_info.major, sys.version_info.minor))")/bin:$PATH
else
    echo "Found pip3: $(pip3 --version)"
fi

# Install boto3 at user level
echo "Installing boto3 via pip3 --user..."
pip3 install --user boto3

# Verify boto3 install
if python3 -c "import boto3" &> /dev/null; then
    echo "boto3 installed successfully."
else
    echo "ERROR: boto3 installation failed."
fi

echo "===== boto3 Installation Script Completed ====="
