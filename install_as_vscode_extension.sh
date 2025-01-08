#!/usr/bin/env bash

# Define the dependencies required for the script
DEPENDENCIES=("npx" "npm" "code")

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

install_dependancies() {
    # Check if /etc/os-release exists
    if [ ! -f /etc/os-release ]; then
        echo "Error: /etc/os-release file not found."
        exit 1
    fi

    # Source the os-release file
    . /etc/os-release

    # Determine the package manager based on the Linux distribution
    install_packages() {
        local package_manager=$1
        local packages=$2
        echo "Installing packages: $packages"
        sudo $package_manager update -y && $package_manager install -y $packages
    }

    # Set package names based on the Linux distribution
    case "$ID" in
        ubuntu|debian)
            echo "Detected: Debian-based distribution"
            packages="cmake tcl-dev libboost-dev python3 python-is-python3"
            echo "Updating package lists and installing packages: $packages"
            sudo apt-get update -y
            sudo apt-get install -y $packages
            ;;
        fedora|rhel|centos|rocky|almalinux)
            echo "Detected: Red Hat-based distribution"
            packages="tcl cmake boost-devel python3"
            echo "Updating package lists and installing packages: $packages"
            sudo dnf update -y
            sudo dnf install -y $packages
            ;;
        arch|manjaro)
            echo "Detected: Arch-based distribution"
            packages="cmake tcl boost python3"
            echo "Updating package lists and installing packages: $packages"
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm $packages
            ;;
        *)
            echo "Error: Unsupported Linux distribution ($ID)"
            exit 1
            ;;
    esac

    # Confirm successful completion
    echo "Installation completed."
}

install_vera()  {
    git clone git@github.com:Epitech/banana-vera.git .vera
    cd .vera

    install_dependancies
    cmake . -DVERA_LUA=OFF -DPANDOC=OFF -DVERA_USE_SYSTEM_BOOST=ON
    make -j
    sudo make install

    cd ..
    rm -fr .vera
}

install_rules()
{
    git clone git@github.com:Epitech/banana-coding-style-checker.git ~/.config/ecsls
}

install_ecsls() {
    CLONE_DIR=".ecsls"

    echo "Cloning repository..."
    git clone "git@github.com:Sigmapitech/ecsls.git" "$CLONE_DIR" ||            \
        git clone "https://github.com/Sigmapitech/ecsls.git" "$CLONE_DIR" ||    \
        { echo "Clone failed"; exit 1; }
    cd "$CLONE_DIR" || { echo "Failed to change directory"; exit 1; }
    python -m venv venv && venv/bin/pip install -e . || { echo "Failed to install ecsls"; exit 1; }
    sudo ln -sf $PWD/venv/bin/ecsls_run /usr/local/bin/ecsls_run || { echo "Failed to create symlink"; exit 1; }
}

install_extension() {
    # Clone the repository
    CLONE_DIR="epitech-cs"

    echo "Cloning repository..."
    git clone "git@github.com:Ciznia/epitech-cs.git" "$CLONE_DIR"            \
        || git clone "https://github.com/Ciznia/epitech-cs.git" "$CLONE_DIR" \
        || { echo "Clone failed"; exit 1; }
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
}

# Run the dependency check
check_dependencies
if ! command -v "vera++" &>/dev/null; then
    install_vera
    install_rules
fi
if ! command -v "ecsls_run" &>/dev/null; then
    install_ecsls
fi

install_extension

echo "Done!"
