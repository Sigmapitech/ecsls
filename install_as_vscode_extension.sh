#!/usr/bin/env bash

# Define the dependencies required for the script
DEPENDENCIES=("npx" "npm" "code")

die() {
    echo $1; exit 1;
}

clone_helper() {
    git clone "git@github.com:$1.git" "$2"
        || git clone "https://github.com/$1.git" "$2"
        || die "Clone failed"
}

# Function to check for dependencies
check_dependencies() {
echo "Checking dependencies..."
    for cmd in "${DEPENDENCIES[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            die "Error: '$cmd' is not installed or not in PATH."
        fi
    done
    echo "All dependencies are installed."
}

install_dependancies() {
    # Check if /etc/os-release exists
    if [ ! -f /etc/os-release ]; then
        die "Error: /etc/os-release file not found."
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
            die "Error: Unsupported Linux distribution ($ID)"
            ;;
    esac

    # Confirm successful completion
    echo "Installation completed."
}

install_vera()  {
    clone_helper "Epitech/banana-vera"  ".vera"
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
    clone "Epitech/banana-coding-style-checker" "~/.config/ecsls"
}

install_ecsls() {
    CLONE_DIR=".ecsls"

    echo "Cloning repository..."
    clone_helper "Sigmapitech/ecsls" $CLONE_DIR
    cd "$CLONE_DIR" || die "Failed to change directory"
    python -m venv venv && venv/bin/pip install -e . || die "Failed to install ecsls"
    sudo ln -sf $PWD/venv/bin/ecsls_run /usr/local/bin/ecsls_run || die "Failed to create symlink"
}

install_extension() {
    # Clone the repository
    CLONE_DIR="epitech-cs"

    echo "Cloning repository..."
    clone_helper "Ciznia/epitech-cs" $CLONE_DIR
    cd "$CLONE_DIR" || die "Failed to change directory"

    # Package the extension
    echo "Packaging the extension..."
    npm i
    VSIX_FILE=$(npx vsce package | grep -oP 'Packaged: \K.*\.vsix')

    # Check if packaging succeeded and install the extension
    if [ -n "$VSIX_FILE" ]; then
        echo "VSIX file found: $VSIX_FILE"
        echo "Installing the extension..."

        code --install-extension "$VSIX_FILE" || die "installation failed"
    else
        die "Error: No .vsix file found in the output."
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
fi
if [ -d ~/.config/ecsls ]; then
    install_rules
fi
if ! command -v "ecsls_run" &>/dev/null; then
    install_ecsls
fi

install_extension

echo "Done!"
