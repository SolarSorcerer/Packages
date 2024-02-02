#!/bin/bash

# Detect the OS from /etc/os-release
OS=$(grep '^ID=' /etc/os-release | cut -d= -f2)

# Fedora, Debian-based systems (Ubuntu, Debian, etc.), and Arch Linux handling
case $OS in
    "fedora")
        echo "Fedora detected. Downloading and installing the RPM package."
        curl -L https://mullvad.net/en/download/app/rpm/latest -o mullvad.rpm
        sudo rpm -i mullvad.rpm
        ;;
    "ubuntu" | "debian" | "pop")
        echo "Debian-based system detected. Downloading and installing the DEB package."
        curl -L https://mullvad.net/en/download/app/deb/latest -o mullvad.deb
        sudo dpkg -i mullvad.deb
        ;;
    "arch")
        echo "Arch Linux detected."

        # Check if yay is installed
        if ! command -v yay &> /dev/null; then
            echo "yay not found. Installing yay from the AUR."
            sudo pacman -Sy git base-devel --needed
            git clone https://aur.archlinux.org/yay.git
            cd yay
            makepkg -si
            cd ..
            rm -rf yay
        else
            echo "yay is already installed."
        fi

        # Install Mullvad VPN using yay
        yay -S mullvad-vpn
        ;;
    *)
        echo "Unsupported OS: $OS"
        ;;
esac
