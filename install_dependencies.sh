#!/bin/bash

# Function to check if a command is available
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to install required dependencies
install_dependencies() {
    local dependencies=(flatpak jq dialog)

    for dependency in "${dependencies[@]}"; do
        if ! command_exists "$dependency"; then
            case "$(uname -s)" in
                Linux*)
                    # Detect the Linux distribution
                    . /etc/os-release

                    case $ID in
                        arch|manjaro)
                            sudo pacman -Syu --noconfirm "$dependency"
                            ;;
                        debian|ubuntu|kali)
                            sudo apt update && sudo apt install -y "$dependency"
                            ;;
                        fedora)
                            sudo dnf install -y "$dependency"
                            ;;
                        *)
                            echo "Your distribution is not supported by this script."
                            exit 1
                            ;;
                    esac
                    ;;
                *)
                    echo "This script is intended to run on Linux systems only."
                    exit 1
                    ;;
            esac
        fi
    done
}

# Install dependencies
install_dependencies
