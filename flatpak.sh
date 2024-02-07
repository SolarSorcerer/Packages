#!/bin/bash

# List of Flatpak packages to install
PACKAGES=(
    "com.spotify.Client"
    "org.videolan.VLC"
    "im.riot.Riot"
    "com.obsproject.Studio"
    "com.bitwarden.desktop"
    "org.telegram.desktop"
    "org.signal.Signal"
    "com.stremio.Stremio"
    "org.qbittorrent.qBittorrent"
    "com.ktechpit.torrhunt"
    "org.audacityteam.Audacity"
    "com.vixalien.sticky"
    "org.gnome.TextEditor"
    "com.getpostman.Postman"
    "org.gnome.Boxes"
    "com.vscodium.codium"
    "com.google.AndroidStudio"
    "com.github.marhkb.Pods"
    "org.cryptomator.Cryptomator"
    "com.github.arshubham.cipher"
    "io.github.dvlv.boxbuddyrs"
    "io.dbeaver.DBeaverCommunity"
    "one.flipperzero.qFlipper"
    "io.github.realmazharhussain.GdmSettings"
    "com.mattjakeman.ExtensionManager"
    "org.torproject.torbrowser-launcher"
    "md.obsidian.Obsidian"
    "net.mullvad.MullvadBrowser"
    "org.keepassxc.KeePassXC"
    "org.kde.kleopatra"
    "com.tutanota.Tutanota"
    "network.loki.Session"
    "io.gitlab.adhami3310.Impression"
    "com.warlordsoftwares.formatlab"
    "org.kde.krita"
    "org.filezillaproject.Filezilla"
    "com.ktechpit.whatsie"
    "io.missioncenter.MissionCenter"
    "com.gitlab.davem.ClamTk"
    "fr.romainvigier.MetadataCleaner"
    "org.bleachbit.BleachBit"
    "org.raspberrypi.rpi-imager"
    "dev.vencord.Vesktop"
    "org.gnome.DejaDup"
    "com.github.finefindus.eyedropper"
    "app.drey.Warp"
    "org.onionshare.OnionShare"
)

# Check for the '--all' argument to install all packages without prompting
INSTALL_ALL=false
if [ "$1" == "--all" ]; then
    INSTALL_ALL=true
fi

# Function to check if Flatpak is installed and install it if it's not
install_flatpak_if_needed() {
    if ! command -v flatpak &> /dev/null; then
        echo "Flatpak is not installed. Attempting to install Flatpak..."

        # Detect the Linux distribution
        . /etc/os-release

        case $ID in
            ubuntu|pop|debian|kali)
                sudo apt update && sudo apt install -y flatpak
                ;;
            arch|manjaro)
                sudo pacman -Syu --noconfirm flatpak
                ;;
            fedora)
                sudo dnf install -y flatpak
                ;;
            *)
                echo "Your distribution is not supported by this script."
                exit 1
        esac

        # Add the Flathub repository
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    else
        echo "Flatpak is already installed."
    fi
}

# Function to install a Flatpak package with optional prompting
install_flatpak_package() {
    local package=$1
    # Check if the package is already installed
    if flatpak list | grep -q $package; then
        echo "$package is already installed, skipping."
        return
    fi

    # Prompt for installation if not in 'install all' mode
    if [ "$INSTALL_ALL" = false ]; then
        read -p "Do you want to install $package? [y/N] " response
        if ! [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            echo "Skipping: $package"
            return
        fi
    fi

    echo "Installing: $package"
    flatpak install -y flathub $package
}

# Ensure Flatpak is installed
install_flatpak_if_needed

# Loop through the packages and prompt for installation if needed
for package in "${PACKAGES[@]}"; do
    install_flatpak_package $package
done

echo "All packages processed."
