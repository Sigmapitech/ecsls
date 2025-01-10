#!/usr/bin/env bash

# Define the dependencies required for the script
DEPENDENCIES=("npx" "npm" "code")

die() {
    echo "$1"
    exit 1
}

clone_helper() {
    git clone "git@github.com:$1.git" "$2" \
        || git clone "https://github.com/$1.git" "$2" \
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

install_dependencies() {
    # Check if /etc/os-release exists
    if [ ! -f /etc/os-release ]; then
        die "Error: /etc/os-release file not found."
    fi

    # Source the os-release file
    . /etc/os-release

    # Set package names based on the Linux distribution
    case "$ID" in
        ubuntu|debian)
            echo "Detected: Debian-based distribution"
            packages=("cmake" "tcl-dev" "python3" "python-is-python3" "libboost-all-dev")
            echo "Updating package lists and installing packages: ${packages[@]}"
            sudo apt-get update -y
            sudo apt-get install -y "${packages[@]}" || die "Failed to install packages"
            ;;
        fedora|rhel|centos|rocky|almalinux)
            echo "Detected: Red Hat-based distribution"
            packages=("tcl-devel" "cmake" "boost-devel" "python3" "boost-devel" "python3.10")
            echo "Updating package lists and installing packages: ${packages[@]}"
            sudo dnf update -y
            sudo dnf install -y "${packages[@]}" || die "Failed to install packages"
            ;;
        arch|manjaro)
            echo "Detected: Arch-based distribution"
            packages=("cmake" "tcl" "python3" "boost-libs")
            echo "Updating package lists and installing packages: ${packages[@]}"
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm "${packages[@]}" || die "Failed to install packages"
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
    cd .vera || die "cd failed"

    install_dependencies || die "dependencies installation failed"
    cmake . -DVERA_LUA=OFF -DPANDOC=OFF -DVERA_USE_SYSTEM_BOOST=ON || die "cmake failed"
    make -j
    sudo make install || die "make failed"

    # Install Python dependencies globally
    echo "Installing global Python dependencies for Vera..."
    python3 -m pip install --user clang libclang || die "Failed to install clang library globally"


    cd ..
    rm -fr .vera
}

install_rules()
{
    clone_helper "Epitech/banana-coding-style-checker" "$HOME/.config/ecsls"
}

install_lsp() {
    CLONE_DIR=".$1"

    echo "Cloning repository..."
    clone_helper "Sigmapitech/$1" $CLONE_DIR
    cd "$CLONE_DIR" || die "Failed to change directory"
    (python -m venv venv && venv/bin/pip install -e .) || die "Failed to install ecsls"
    local TARGET_PATH="$PWD/venv/bin/${1}_run"
    sudo ln -sf "$TARGET_PATH" "/usr/local/bin/${1}_run" || die "Failed to create symlink"
    cd ..
}

install_ecsls() {
    install_lsp "ecsls"
}

install_lambdananas() {
    curl -L https://github.com/Epitech/lambdananas/releases/download/v2.4.3.2/lambdananas > lambdananas
    chmod +x lambdananas
    sudo mv ./lambdananas /usr/local/bin/
}

install_ehcsls() {
    install_lsp "ehcsls"
}

install_extension() {
    echo "Cloning repository..."
    clone_helper "Ciznia/$1" $1
    cd "$1" || die "Failed to change directory"

    # Package the extension
    echo "Packaging the extension..."
    npm i || die "failed to install npm dependencies"
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
    rm -rf "$1"
}

# Run the dependency check
check_dependencies
if ! command -v "vera++" &>/dev/null; then
    install_vera
fi
if ! [ -d ~/.config/ecsls ]; then
    install_rules
fi
if ! command -v "ecsls_run" &>/dev/null; then
    install_ecsls
fi
if ! command -v "lambdananas" &>/dev/null; then
    install_lambdadanas
fi
if ! command -v "ehcsls_run" &>/dev/null; then
    install_ehcsls
fi

install_extension "epitech-cs"
install_extension "epitech-hcs"

echo "Done!"
