#!/bin/bash

# Check if packages.json file exists
if [ ! -f "packages.json" ]; then
    echo "Error: packages.json file not found."
    exit 1
fi

# Install dependencies
./install_dependencies.sh

# Function to install a Flatpak package
install_flatpak_package() {
    local package_id="$1"

    # Check if the package is already installed
    if flatpak list | grep -q "$package_id"; then
        echo "$package_id is already installed, skipping."
        return
    fi

    echo "Installing: $package_id"
    flatpak install -y flathub "$package_id"
}

# Function to display package selection dialog
show_package_selection_dialog() {
    local dialog_args=("--stdout" "--clear" "--checklist" "Select packages to install:" 20 60 0)

    # Read package IDs from packages.json
    local packages=($(jq -r '.packages | .[]' packages.json))

    # Populate dialog arguments with package list
    for package in "${packages[@]}"; do
        dialog_args+=("$package" "" on)  # Select packages by default
    done

    # Run dialog and capture user selection
    dialog "${dialog_args[@]}"
}

# Function to add a new application to the packages list
add_application() {
    local new_package
    new_package=$(dialog --clear --stdout --inputbox "Enter the Flatpak ID of the application you want to add:" 0 0)
    # Check if the user canceled or entered an empty value
    if [ -z "$new_package" ]; then
        echo "No application ID provided. Canceling."
        return
    fi
    # Check if the new package is already in the list
    if jq -e --arg new_package "$new_package" '.packages | index($new_package)' packages.json > /dev/null; then
        echo "Package already exists in the list."
        return
    fi
    # Add the new package to the JSON file
    jq --arg new_package "$new_package" '.packages += [$new_package]' packages.json > temp.json
    mv temp.json packages.json
    echo "Application added: $new_package"
}

# Function to remove an application from the packages list
remove_application() {
    local packages_count=$(jq length packages.json)
    if [ "$packages_count" -eq 0 ]; then
        echo "No applications to remove."
        return
    fi

    local dialog_args=("--stdout" "--clear" "--menu" "Select an application to remove:" 20 60 0)

    # Read package IDs from packages.json
    local packages=($(jq -r '.packages | .[]' packages.json))

    # Populate dialog arguments with package list
    local i=1
    for package in "${packages[@]}"; do
        dialog_args+=("$i" "$package")
        ((i++))
    done

    # Run dialog and capture user selection
    local selected=$(dialog "${dialog_args[@]}")
    if [ -n "$selected" ]; then
        local index=$((selected - 1))
        local removed_package="${packages[index]}"
        unset 'packages[index]'
        jq 'del(.packages['"$index"'])' packages.json > temp.json
        mv temp.json packages.json
        echo "Application removed: $removed_package"
    fi
}



# Main menu
while true; do
    dialog --clear --stdout --menu "Main Menu" 20 60 5 \
        1 "Install Applications" \
        2 "Add Application" \
        3 "Remove Application" \
        4 "Exit" \
        > main_menu_choice

    choice=$(<main_menu_choice)

    case $choice in
        1)
            show_package_selection_dialog
            ;;
        2)
            add_application
            ;;
        3)
            remove_application
            ;;
        4)
            rm main_menu_choice
            exit
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done
