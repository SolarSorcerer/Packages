# Arch Linux Package Manager Script

This script automates the installation of system and Flatpak packages on Arch Linux, ensuring efficient package management by checking for the presence of packages before attempting installation. It supports installing packages from the official repositories, AUR (using `yay`), and Flatpak.

## Prerequisites

Before running this script, you need `git` for cloning repositories (if necessary) and sudo privileges for installing packages.

## Installation

1. **Clone the repository or download the script** to your local machine.

2. **Make the script executable**:
    ```bash
    chmod +x pm.sh
    ```

3. **Run the script** from the directory where it's located:
    ```bash
    ./pm.sh
    ```

The script automatically checks for and installs `yay`, `jq`, and `flatpak` if they are not present on your system.

## Configuring Your Packages

Find the `packages.json` file in the same directory as the script, specifying the system and Flatpak packages you wish to install. Example :

```json
{
  "system-packages": [
    "firefox",
    "vlc",
    "git"
  ],
  "flatpak-packages": [
    "com.spotify.Client",
    "org.signal.Signal"
  ]
}
