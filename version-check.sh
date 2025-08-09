#!/bin/bash

echo "=== DEVELOPMENT ENVIRONMENT VERSIONS ==="
echo

# Array to store outdated tools for update prompts
declare -a outdated_tools=()

# Fast loading animation function
show_loading() {
    local message="$1"
    echo -n "$message"
    for i in {1..8}; do
        echo -n "."
        sleep 0.2
    done
    echo " Done!"
}

# Fast version check function (no update checking)
check_version() {
    local cmd="$1"
    local display_name="$2"
    local custom_format="$3"
    local version_output
    
    if command -v $(echo $cmd | awk '{print $1}') >/dev/null 2>&1; then
        version_output=$(eval "$cmd" 2>/dev/null)
        
        if [ -n "$custom_format" ]; then
            version=$(echo "$version_output" | eval "$custom_format")
        else
            version=$(echo "$version_output" | grep -oE 'v?[0-9]+(\.[0-9]+)*' | head -1 | sed 's/^v//')
            
            if [ -z "$version" ]; then
                version=$(echo "$version_output" | grep -i version | grep -oE '[0-9]+(\.[0-9]+)*' | head -1)
            fi
        fi
        
        if [ -n "$version" ]; then
            echo "$display_name - $version"
        else
            echo "$display_name - Installed (version detection failed)"
        fi
    else
        echo "$display_name - Not installed"
    fi
}

# Function to check for updates with pipx for pip management
check_for_updates() {
    show_loading "🔄 Checking for updates"
    echo
    
    # Check Node.js (manual update only)
    if command -v node >/dev/null 2>&1; then
        current=$(node --version 2>/dev/null | sed 's/v//')
        latest=$(curl -s https://nodejs.org/dist/index.json | jq -r '.[0].version' 2>/dev/null | sed 's/v//')
        if [ -n "$latest" ] && [ "$current" != "$latest" ]; then
            echo "📦 Node.js update available: $current → $latest"
            echo "   Please update manually: https://nodejs.org or use nvm"
            echo
        fi
    fi
    
    # Check NPM
    if command -v npm >/dev/null 2>&1; then
        current=$(npm --version 2>/dev/null)
        latest=$(npm view npm version 2>/dev/null)
        if [ -n "$latest" ] && [ "$current" != "$latest" ]; then
            outdated_tools+=("NPM|$current|$latest|npm install -g npm@latest")
        fi
    fi
    
    # Check Git
    if command -v git >/dev/null 2>&1; then
        current=$(git --version 2>/dev/null | awk '{print $3}')
        latest=$(apt list --upgradable 2>/dev/null | grep "^git/" | awk -F'[ /]' '{print $3}' 2>/dev/null)
        if [ -n "$latest" ] && [ "$current" != "$latest" ]; then
            outdated_tools+=("Git|$current|$latest|sudo apt update && sudo apt upgrade git -y")
        fi
    fi
    
    # Check Vim
    if command -v vim >/dev/null 2>&1; then
        current=$(vim --version 2>/dev/null | head -1 | grep -o '[0-9]\+\.[0-9]\+')
        latest=$(apt list --upgradable 2>/dev/null | grep "^vim/" | awk -F'[ /]' '{print $3}' 2>/dev/null)
        if [ -n "$latest" ] && [ "$current" != "$latest" ]; then
            outdated_tools+=("Vim|$current|$latest|sudo apt update && sudo apt upgrade vim -y")
        fi
    fi
    
    # Check Python
    if command -v python3 >/dev/null 2>&1; then
        current=$(python3 --version 2>/dev/null | awk '{print $2}')
        latest=$(apt list --upgradable 2>/dev/null | grep "^python3/" | awk -F'[ /]' '{print $3}' 2>/dev/null)
        if [ -n "$latest" ] && [ "$current" != "$latest" ]; then
            outdated_tools+=("Python|$current|$latest|sudo apt update && sudo apt upgrade python3 -y")
        fi
    fi
    
    # Check pip3 using pipx approach (safe and isolated)
    if command -v pip3 >/dev/null 2>&1; then
        current=$(pip3 --version 2>/dev/null | awk '{print $2}')
        # Check if pipx has pip installed
        pipx_pip_version=$(pipx list 2>/dev/null | grep "^pip" | awk '{print $2}' || echo "")
        
        if [ -n "$pipx_pip_version" ]; then
            # pip is managed by pipx, check for updates
            latest=$(pipx list --include-injected 2>/dev/null | grep "^pip" | grep -o "upgradeable to [0-9.]*" | awk '{print $3}' || echo "")
            if [ -n "$latest" ]; then
                outdated_tools+=("Pip (pipx)|$pipx_pip_version|$latest|pipx upgrade pip")
            fi
        else
            # pip not in pipx, offer to install it there
            latest=$(curl -s https://pypi.org/pypi/pip/json 2>/dev/null | jq -r '.info.version' 2>/dev/null || echo "")
            if [ -n "$latest" ] && [ "$current" != "$latest" ]; then
                outdated_tools+=("Pip|$current|$latest|pipx install pip --force")
            fi
        fi
    fi
    
    # Check yt-dlp (since it's managed by pipx)
    if command -v yt-dlp >/dev/null 2>&1; then
        current=$(yt-dlp --version 2>/dev/null)
        # Check if yt-dlp has updates via pipx
        if pipx list 2>/dev/null | grep -q "yt-dlp"; then
            latest=$(pipx list --include-injected 2>/dev/null | grep "yt-dlp" | grep -o "upgradeable to [0-9.-]*" | awk '{print $3}' || echo "")
            if [ -n "$latest" ]; then
                outdated_tools+=("yt-dlp|$current|$latest|pipx upgrade yt-dlp")
            fi
        fi
    fi
}

# Function to offer updates
offer_updates() {
    if [ ${#outdated_tools[@]} -eq 0 ]; then
        echo "🎉 All checked tools are up to date!"
        return
    fi
    
    echo
    echo "📋 AVAILABLE UPDATES"
    echo "==================="
    
    for tool_info in "${outdated_tools[@]}"; do
        IFS='|' read -r name current latest cmd <<< "$tool_info"
        echo "📦 $name: $current → $latest"
    done
    
    echo
    read -p "🔄 Would you like to update these tools? (y/n): " update_choice
    
    if [[ $update_choice == "y" ]] || [[ $update_choice == "Y" ]]; then
        echo
        echo "💻 UPDATING TOOLS"
        echo "================="
        
        for tool_info in "${outdated_tools[@]}"; do
            IFS='|' read -r name current latest cmd <<< "$tool_info"
            echo
            echo "📦 $name ($current → $latest):"
            echo "   Command: $cmd"
            echo
            read -p "🚀 Update $name now? (y/n): " update_now
            
            if [[ $update_now == "y" ]] || [[ $update_now == "Y" ]]; then
                echo "⏳ Updating $name..."
                if eval "$cmd"; then
                    echo "✅ $name updated successfully!"
                else
                    echo "❌ Failed to update $name. Please run manually: $cmd"
                fi
            else
                echo "⏭️  Skipped $name update"
            fi
        done
    else
        echo "⏭️  Updates skipped"
    fi
}

# Fast auto-detect function
auto_detect_tools() {
    echo
    echo "🔍 Auto-detected additional tools:"
    
    local tools=(
        "flutter --version|Flutter|head -1 | awk '{print \$2}'"
        "rustc --version|Rust|awk '{print \$2}'"
        "go version|Go|awk '{print \$3}' | sed 's/go//'"
        "yarn --version|Yarn"
        "pnpm --version|PNPM"
        "code --version|VS Code|head -1"
        "nvim --version|Neovim|head -1 | awk '{print \$2}'"
        "vim --version|Vim|head -1 | grep -o '[0-9]\\+\\.[0-9]\\+'"
        "neofetch --version|Neofetch"
        "yt-dlp --version|yt-dlp"
    )
    
    local found_any=false
    for tool in "${tools[@]}"; do
        IFS='|' read -r cmd name format <<< "$tool"
        if command -v $(echo $cmd | awk '{print $1}') >/dev/null 2>&1; then
            check_version "$cmd" "$name" "$format"
            found_any=true
        fi
    done
    
    if [ "$found_any" = false ]; then
        echo "No additional development tools detected"
    fi
}

# === MAIN EXECUTION (FAST PART) ===

# System Information
echo "System Information:"
echo "Ubuntu - $(lsb_release -rs 2>/dev/null || echo 'Unknown')"
echo "WSL - $(grep -i microsoft /proc/version >/dev/null 2>&1 && echo 'WSL2' || echo 'Unknown')"
echo

# Shell Environment
echo "Shell Environment:"
check_version "zsh --version" "Zsh" "awk '{print \$2}'"
echo "Oh My Zsh - $([ -d ~/.oh-my-zsh ] && echo 'Installed' || echo 'Not installed')"
echo

# Core Programming Languages
echo "Programming Languages:"
check_version "python3 --version" "Python" "awk '{print \$2}'"
check_version "node --version" "Node.js" "sed 's/v//'"
check_version "npm --version" "NPM"
echo

# Development Tools
echo "Development Tools:"
check_version "gcc --version" "GCC" "head -1 | awk '{print \$4}'"
check_version "make --version" "Make" "head -1 | awk '{print \$3}'"
check_version "cmake --version" "CMake" "head -1 | awk '{print \$3}'"
check_version "git --version" "Git" "awk '{print \$3}'"
echo

# Web Development
echo "Web Development:"
check_version "express --version" "Express"
check_version "create-react-app --version" "Create React App" "tail -1"
echo

# Databases & Services  
echo "Databases & Services:"
check_version "mongod --version" "MongoDB" "head -1 | grep -o 'v[0-9]*\\.[0-9]*\\.[0-9]*' | sed 's/v//'"
check_version "mongosh --version" "MongoDB Shell" "awk '{print \$1}'"
check_version "docker version --format '{{.Client.Version}}'" "Docker"
echo

# Package Managers & Tools
echo "Package Managers & Tools:"
check_version "pip3 --version" "Pip" "awk '{print \$2}'"
check_version "pipx --version" "pipx" "awk '{print \$2}'"

# Auto-detect additional tools
auto_detect_tools

echo
echo "=== SCRIPT COMPLETED ==="

# === UPDATE CHECK PART (OPTIONAL) ===
echo
read -p "🔄 Check for updates? (y/n): " check_updates

if [[ $check_updates == "y" ]] || [[ $check_updates == "Y" ]]; then
    check_for_updates
    offer_updates
else
    echo "⏭️  Update check skipped"
fi

echo
echo "💡 Script completed successfully!"
echo "💡 For Python packages, use 'pipx install package-name' for isolated management"
