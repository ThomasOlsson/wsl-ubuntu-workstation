# WSL Ubuntu Workstation Setup

**One-command setup for a fully configured Ubuntu development environment in WSL with your dotfiles.**

## 🚀 Quick Start

### 1. Run Setup (One Command)
```powershell
.\setup.ps1
```

### 2. Complete Dotfiles Setup (2 Simple Steps)
```bash
# Access your workstation and go to home directory
wsl -d ubuntu-workstation
cd ~

# 1. Copy your private SSH key and pull dotfiles
cp /mnt/c/Users/"Thomas Olsson"/.ssh/id_ed25519 ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519
ssh-keyscan github.com >> ~/.ssh/known_hosts
yadm pull

# 2. Run bootstrap to install everything
yadm bootstrap
```

**That's it!** Your complete development environment is ready. 🎉

## 🎯 What This Creates

A production-ready Ubuntu WSL instance named `ubuntu-workstation` with:

- ✅ **User `kingo`** with sudo privileges (password: `kingo`)
- ✅ **SSH keys configured** (GitHub import + direct fallback)
- ✅ **YADM pre-configured** with your dotfiles repository
- ✅ **Git configured** with sensible defaults
- ✅ **Homebrew prerequisites** installed for your bootstrap
- ✅ **Security hardened** (password auth disabled, key-only access)

## 🤖 **For AI Agents - Automated Testing**

Follow these exact steps to test the complete setup:

```powershell
# Step 1: Remove any existing instance and run setup
wsl --unregister ubuntu-workstation
.\setup.ps1

# Step 2: Copy SSH key and pull dotfiles using YADM
wsl -d ubuntu-workstation -- bash -c 'cd ~ && cp /mnt/c/Users/"Thomas Olsson"/.ssh/id_ed25519 ~/.ssh/id_ed25519 && chmod 600 ~/.ssh/id_ed25519 && ssh-keyscan github.com >> ~/.ssh/known_hosts && yadm pull origin main'

# Step 3: Run bootstrap
wsl -d ubuntu-workstation -- bash -c 'yadm bootstrap'

# Step 4: Verify everything works  
wsl -d ubuntu-workstation -- bash -lc 'cd ~ && echo "=== VERIFICATION ===" && whoami && yadm status && brew --version'
```

## 💡 How It Works

1. **Cloud-Init Setup**: Installs YADM, SSH tools, and Homebrew prerequisites
2. **YADM Pre-configured**: Repository already configured, just pull and bootstrap
3. **Bootstrap Does Everything**: Installs Homebrew, development tools, and configures everything

## 🔧 Troubleshooting

**Reset and try again:**
```powershell
wsl --unregister ubuntu-workstation
.\setup.ps1
```

**Check logs:**
```bash
wsl -d ubuntu-workstation -- sudo cloud-init status
wsl -d ubuntu-workstation -- sudo cat /var/log/cloud-init.log
```

**Manual YADM setup (if needed):**
```bash
yadm init
yadm remote add origin git@github.com:ThomasOlsson/dotfiles-workstation.git
yadm pull origin main
yadm bootstrap
```

## 📂 Files

```
WSL/
├── setup.ps1                    # Main setup script
├── ubuntu-workstation.user-data # Cloud-init configuration
└── README.md                   # This guide
```

---

**🎯 Pre-configured for Thomas with GitHub username `ThomasOlsson` and SSH key ready to go!**