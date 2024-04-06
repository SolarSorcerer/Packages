#!/bin/bash

# Define the packages.json file path
PACKAGES_FILE="packages.json"

# Check for the packages.json file and prompt to create if not found
check_or_create_packages_file() {
    if [ ! -f "$PACKAGES_FILE" ]; then
        echo "$PACKAGES_FILE does not exist."
        read -p "Do you want to create it? [y/N]: " response
        case "$response" in
            [yY][eE][sS]|[yY]) 
                echo '{"system-packages": [], "flatpak-packages": []}' > "$PACKAGES_FILE"
                echo "$PACKAGES_FILE has been created with default content."
                ;;
            *)
                echo "Cannot proceed without $PACKAGES_FILE. Exiting."
                exit 1
                ;;
        esac
    fi
}

#!/bin/bash

# Function to check and install necessary utilities
ensure_utilities() {
    # Ensure yay is installed
    if ! command -v yay &> /dev/null; then
        echo "Installing yay, the AUR helper..."
        sudo pacman -Sy --needed git base-devel
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si
        cd ..
        rm -rf yay
    else
        echo "yay is already installed."
    fi

    # Ensure jq is installed
    if ! command -v jq &> /dev/null; then
        echo "jq is not installed. Installing jq..."
        sudo pacman -Sy jq
    else
        echo "jq is already installed."
    fi

    # Ensure flatpak is installed
    if ! command -v flatpak &> /dev/null; then
        echo "Flatpak is not installed. Installing Flatpak..."
        yay -Sy flatpak
    else
        echo "Flatpak is already installed."
    fi
}

# Rest of your script including the package installation functions



# Install system packages
install_system_packages() {
    echo "Checking for system packages to install..."
    local system_packages=($(jq -r '.["system-packages"][]' "$PACKAGES_FILE"))
    if [ ${#system_packages[@]} -eq 0 ]; then
        echo "No system packages to install."
        return
    fi

    for package in "${system_packages[@]}"; do
        # Check if the package is already installed
        if pacman -Qi "$package" &> /dev/null; then
            echo "$package is already installed, skipping."
        else
            echo "Installing: $package"
            yay -S --noconfirm "$package"
        fi
    done
}

# Install Flatpak packages
install_flatpak_packages() {
    echo "Checking for Flatpak packages to install..."
    local flatpak_packages=($(jq -r '.["flatpak-packages"][]' "$PACKAGES_FILE"))
    if [ ${#flatpak_packages[@]} -eq 0 ]; then
        echo "No Flatpak packages to install."
        return
    fi

    # Fetch list of already installed Flatpak apps
    local installed_flatpaks=$(flatpak list --columns=app)
    
    for package in "${flatpak_packages[@]}"; do
        if echo "$installed_flatpaks" | grep -Fxq "$package"; then
            echo "$package is already installed, skipping."
        else
            echo "Installing: $package"
            flatpak install -y flathub "$package"
        fi
    done
}


# Main script logic
check_or_create_packages_file
ensure_utilities
install_system_packages
install_flatpak_packages
