#!/usr/bin/env bash

# Define the dependencies required for the script
DEPENDENCIES=("npx" "npm" "code" "python")

# Function to check for dependencies
check_dependencies() {
echo "Checking dependencies..."
    for cmd in "${DEPENDENCIES[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "Error: '$cmd' is not installed or not in PATH."
            exit 1
        fi
    done
    echo "All dependencies are installed."
}

# Run the dependency check
check_dependencies


# Clone ecsls
REPO_URL="git@github.com/Sigmapitech/ecsls.git"
CLONE_DIR="ecsls"

echo "Cloning repository..."
git clone "git@github.com/Sigmapitech/ecsls.git" "$CLONE_DIR" ||            \
    git clone "https://github.com/Sigmapitech/ecsls.git" "$CLONE_DIR" ||    \
    { echo "Clone failed"; exit 1; }
cd "$CLONE_DIR" || { echo "Failed to change directory"; exit 1; }
python -m venv venv && venv/bin/pip install -e .
ln -sf venv/bin/ecsls_run /usr/bin/ecsls_run

# Clone the repository
CLONE_DIR="epitech-cs"

echo "Cloning repository..."
git clone "git@github.com/Ciznia/epitech-cs.git" "$CLONE_DIR" ||            \
    git clone "https://github.com/Ciznia/epitech-cs.git" "$CLONE_DIR" ||    \
    { echo "Clone failed"; exit 1; }
cd "$CLONE_DIR" || { echo "Failed to change directory"; exit 1; }

# Package the extension
echo "Packaging the extension..."
npm i
VSIX_FILE=$(npx vsce package | grep -oP 'Packaged: \K.*\.vsix')

# Check if packaging succeeded and install the extension
if [ -n "$VSIX_FILE" ]; then
  echo "VSIX file found: $VSIX_FILE"
  echo "Installing the extension..."
  code --install-extension "$VSIX_FILE" || { echo "Installation failed"; exit 1; }
else
  echo "Error: No .vsix file found in the output."
  exit 1
fi

# Return to the original directory and clean up
cd ..
echo "Cleaning up..."
rm -rf "$CLONE_DIR"

echo "Done!"
