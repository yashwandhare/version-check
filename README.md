# Development Environment Version Checker

A simple Bash script that checks the installed versions of common development tools and offers to update them with your confirmation.  
It automatically detects popular programming languages, package managers, and utilities.

---

## **Features**
- 🔍 **Version Check** – Lists installed versions of common development tools.
- ⚡ **Update Prompt** – Offers to update outdated tools (with user confirmation).
- 🛠 **Auto-Detection** – Automatically finds tools installed on your system.
- 📦 **Dependency Installer** – Installs required dependencies if missing.

---

## **Installation**
```bash
# Clone the repository
git clone git@github.com:yashwandhare/version-check.git
cd version-check

# Move script to ~/bin and make it executable
cp version-check.sh ~/bin/version-check
chmod +x ~/bin/version-check

# Add alias to your shell configuration (Zsh example)
echo 'alias version-check="~/bin/version-check"' >> ~/.zshrc
source ~/.zshrc
```

---

## **Dependencies**
The script will automatically install the following if they’re not already present:  
- `curl`
- `jq`
- `pipx`

Manual install:
```bash
sudo apt update
sudo apt install curl jq pipx -y
```

---

## **Usage**
```bash
version-check
```
- The script will scan your system for development tools.  
- It will display their installed versions.  
- You can choose whether to update each tool.

---

## **Example Output**
```
Node.js: v20.5.1 (Update available: v20.6.0) → Update? [y/N]
Python: 3.11.4 (Up to date)
Git: 2.42.0 (Up to date)
```

---

## **License**
This project is open-source under the MIT License.