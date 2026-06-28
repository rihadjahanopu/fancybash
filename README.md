<div align="center">

<br>

```
          ███████╗ █████╗ ███╗   ██╗ ██████╗██╗   ██╗██████╗  █████╗ ███████╗██╗  ██╗
          ██╔════╝██╔══██╗████╗  ██║██╔════╝╚██╗ ██╔╝██╔══██╗██╔══██╗██╔════╝██║  ██║
          █████╗  ███████║██╔██╗ ██║██║      ╚████╔╝ ██████╔╝███████║███████╗███████║
          ██╔══╝  ██╔══██║██║╚██╗██║██║       ╚██╔╝  ██╔══██╗██╔══██║╚════██║██╔══██║
          ██║     ██║  ██║██║ ╚████║╚██████╗   ██║   ██████╔╝██║  ██║███████║██║  ██║
          ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
```

### ⚡ The Ultimate Bash Environment for Modern Developers

_Beautiful • Fast • Smart • Zero Bloat_

<br>

[![MIT License](https://img.shields.io/badge/License-MIT-a855f7?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Bash-22c55e?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-0ea5e9?style=for-the-badge&logo=linux&logoColor=white)](#)
[![Stars](https://img.shields.io/github/stars/rihadjahanopu/fancybash?style=for-the-badge&logo=github&color=f59e0b&logoColor=white)](https://github.com/rihadjahanopu/fancybash)
[![Version](https://img.shields.io/badge/Version-2.0-ec4899?style=for-the-badge)](#)
[![Website](https://img.shields.io/badge/Website-fancybash.netlify.app-22d3ee?style=for-the-badge&logo=netlify&logoColor=white)](https://fancybash.netlify.app)

<br>

<img src="https://i.postimg.cc/pXB6h98T/terminal2.png" alt="fancybash terminal preview 1" width="85%">
<br><br>
<img src="https://i.postimg.cc/tCzMZ1P1/terminal1.png" alt="fancybash terminal preview 2" width="85%">

<br>

**🌐 Live Website: [fancybash.netlify.app](https://fancybash.netlify.app)**

</div>

---

## 📌 Table of Contents

- [✨ What is fancybash?](#-what-is-fancybash)
- [🌟 Feature Highlights](#-feature-highlights)
- [🚀 Quick Install](#-quick-install)
- [🗑️ Uninstall](#️-uninstall)
- [⚙️ Font Setup](#️-font-setup-for-emoji--icons)
- [📟 Smart Prompt](#-smart-prompt-system)
- [🛠️ Command Reference](#️-command-reference)
  - [📂 Navigation](#-navigation--movement)
  - [📦 Package Managers](#-npm--bun-commands)
  - [🌿 Git Shortcuts](#-git-version-control)
  - [🔧 Project Setup](#-project-initialization)
  - [⚙️ System Tools](#-system--maintenance)
  - [🔨 Utilities](#-utility-tools)
- [🏗️ Project Structure](#️-project-structure)
- [🖥️ Zed IDE Settings](#️-zed-ide-settings)
- [🐧 Linux App Ecosystem](#-linux-app-ecosystem)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## ✨ What is fancybash?

**fancybash** is a production-ready, opinionated Bash configuration designed for modern web developers. It replaces your dull terminal with a fully-featured, intelligent shell environment — without the overhead of frameworks like Oh My Zsh.

One file. One install. Zero drama.

> Built by a developer, for developers — with Node.js, Bun, Git, and Linux workflows baked in.

---

## 🌟 Feature Highlights

| Feature                      | Description                                                                         |
| ---------------------------- | ----------------------------------------------------------------------------------- |
| ⚡ **Lightning Fast**        | No heavy plugins or slow git parsing — stays snappy even on old hardware            |
| 🛡️ **100% Safe Install**     | Never blindly overwrites `.bashrc` — creates a timestamped backup every time        |
| 🔄 **Idempotent**            | Running the installer multiple times is always safe — detects existing installs     |
| 🌈 **Dynamic Prompt**        | Rainbow colors, random emoji per folder type, git branch with dirty state indicator |
| 🟢 **Node.js First-Class**   | Built-in `nvm` support, Node/NPM/Bun version display, and instant aliases           |
| 🥐 **Bun First-Class**       | `bi`, `brd`, `brb`, `brs` shortcuts — runs `.ts` files with zero config             |
| 🔧 **Single Config File**    | Everything lives in `config.sh` — easy to read, fork, and customize                 |
| 📦 **Universal Uninstaller** | `uu` — interactive fuzzy app remover with `fzf`, supports apt/snap/flatpak/AppImage |
| 🔁 **Mega Updater**          | `uup` — updates OS + Snap + Flatpak + Bun + Node.js in one interactive command      |
| 🌡️ **System Health Prompt**  | CPU temp with color-coded alerts, disk space, load average, command timer           |
| 🔑 **Secret Key Generator**  | `gen 32` — cryptographically secure random key generation via OpenSSL               |
| 🗜️ **Universal Extractor**   | `ex` — handles `.zip`, `.tar.gz`, `.rar`, `.7z`, `.bz2` and more                    |

---

## 🚀 Quick Install

> **Requirements:** `curl`, `bash` — that's it.

### One-Line Install (Recommended)

**For Bash (`.bashrc`):**

```bash
bash <(curl -fsSL https://gist.githubusercontent.com/rihadjahanopu/a1c286e48b3ecee1a207c759279e352c/raw/install.sh)
```

**For Zsh (`.zshrc`):**

```zsh
zsh <(curl -fsSL https://gist.githubusercontent.com/rihadjahanopu/fa5874bf928c2416816b7092030f1f3b/raw/install.zsh)
```

**For PowerShell (`$PROFILE`):**

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex (irm https://gist.githubusercontent.com/rihadjahanopu/54b3d3bf8aac456b1aa19a62ac76a993/raw/install.ps1)
```

The installer will:

1. ✅ Check for existing installation (safe to re-run)
2. 💾 Create a timestamped backup of your current shell configuration
3. 📥 Download and append the config with boundary markers
4. 🔄 Automatically reload your shell

### Manual Install (Clone & Source)

```bash
git clone https://github.com/rihadjahanopu/fancybash.git
cd fancybash

# For Bash:
cat config.sh >> ~/.bashrc
source ~/.bashrc

# For Zsh:
cat config.zsh >> ~/.zshrc
source ~/.zshrc

# For PowerShell:
.\install.ps1
```

---

## 🗑️ Uninstall

Cleanly removes **only** the fancybash block from your config file, leaving the rest untouched:

**For Bash:**

```bash
sed -i '/# >>> fancy-bashrc >>>/,/# <<< fancy-bashrc <<</d' ~/.bashrc && source ~/.bashrc
```

**For Zsh:**

```zsh
sed -i '/# >>> fancy-zshrc >>>/,/# <<< fancy-zshrc <<</d' ~/.zshrc && source ~/.zshrc
```

**For PowerShell:**

```powershell
$p = $PROFILE; (Get-Content $p -Raw) -replace '(?s)# >>> fancy-powershell >>>.*?# <<< fancy-powershell <<<\s*', '' | Set-Content $p
```

> 💡 Your original config remains untouched — only the `fancybash` block wrapped in `>>> / <<<` markers is removed.

---

## 🦄 Zsh Setup Guide

Install Zsh, set it as your default shell, and supercharge it with syntax highlighting and autosuggestions — no framework needed.

### 1 — Install Git & Zsh

For Ubuntu/Debian-based systems:

```bash
sudo apt update && sudo apt install git zsh -y
```

### 2 — Verify & Set as Default

Check the installed version, then set Zsh as your default shell. Log out and back in for this to take effect.

```bash
zsh --version
chsh -s $(which zsh)
```

### 3 — Create Plugin Folder

fancybash (`config.zsh`) automatically loads plugins if they are present in the `~/.zsh/` directory.

```bash
mkdir -p ~/.zsh
```

### 4 — Install Plugins via Git

Clone both plugins directly — no plugin manager required.

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh/zsh-autosuggestions
```

### 5 — Restart your terminal

Open a new terminal window. fancybash will auto-source the plugins and everything will work automatically!

---

## ⚙️ Font Setup (for Emoji & Icons)

fancybash uses color emoji and Fira Code ligatures in the prompt. Follow these steps for the best experience:

### 1 — Install Emoji Font

```bash
sudo apt install fonts-noto-color-emoji
```

### 2 — Install Fonts (Programming Fonts)

```bash
sudo apt update && sudo apt install -y fonts-firacode fonts-cascadia-code
```

### 3 — Set Font Priority

```bash
sudo nano /etc/fonts/local.conf
```

Paste the following config:

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>Fira Code</family>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>

  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
</fontconfig>
```

### 4 — Rebuild Font Cache

```bash
fc-cache -fv
```

### 5 — Set System Locale (if emoji still broken)

```bash
echo -e "LANG=en_US.UTF-8\nLC_ALL=en_US.UTF-8\nLANGUAGE=en_US" | sudo tee /etc/default/locale
sudo locale-gen en_US.UTF-8
sudo update-locale
reboot
```

---

## 📟 Smart Prompt System

fancybash renders a smart two-part prompt with contextual awareness:

```
🚀 myproject                          ← Emoji (auto by folder name) + colored folder
❯❯❯                                   ← Blinking cursor arrow (Line 2)
```

**Prompt features include:**

| Element            | Description                                                                                   |
| ------------------ | --------------------------------------------------------------------------------------------- |
| `rand_emoji`       | Folder-aware emoji — `🌐` for web, `🟢` for node, `🥐` for bun, `🐍` for py, random otherwise |
| `rand_color`       | Rainbow color cycle on every prompt render                                                    |
| `parse_git_branch` | Shows `branchname ❗` when working tree is dirty                                              |
| `cpu_temp`         | 🟢 Green / 🟡 Yellow / 🔴 Red based on temperature thresholds                                 |
| `disk_usage`       | Shows free disk space on `/`                                                                  |
| `load_avg`         | System load average                                                                           |
| `get_duration`     | Shows `⏱️ Ns` for any command taking longer than 1 second                                     |
| `check_readonly`   | Shows `🔒` when current directory is not writable                                             |
| `pending_updates`  | Shows `🆙 N` if system packages need updating                                                 |
| `battery_info`     | Shows battery % when available                                                                |
| `kernel_version`   | Displays current kernel version                                                               |

### ⚙️ Customizing the Prompt Layout

By default, fancybash/fancyzsh renders a clean, minimalistic **single-line** prompt. However, all the dynamic system monitoring metrics listed above (such as CPU temp, disk space, active runtime versions) are already built-in and ready to be used.

You can modify or toggle the prompt layout to your liking by editing your shell configuration file (`~/.bashrc` or `~/.zshrc`) and uncommenting/commenting the lines under the **`🎯 TWO LINE PROMPT`** section:

```bash
# 💡 Uncomment these lines in your ~/.bashrc or ~/.zshrc if you want the full two-line prompt:
# PS1="\$(rand_emoji) \[\033[\$(rand_color)m\]\W\[\033[0m\] "
# PS1+="\$(folder_size) [🌿 \$(parse_git_branch)]\$(cpu_temp) \$(disk_usage) \$(load_avg) \$(get_duration) \$(check_readonly) \$(pending_updates)\n"
# PS1+="\$(node_version) │ \$(npm_version) │ \$(bun_version) │ \$(kernel_version) │ "
# PS1+="\$(time_date) │ \$(sys_info) │ \$(battery_info)\n"
```

Feel free to customize, add, or remove any helper functions (like `node_version`, `cpu_temp`, etc.) from your configuration block to design your own custom layout!

---

## 🛠️ Command Reference

> Run `keep` in your terminal to see this full reference at any time.

---

### 📂 Navigation & Movement

| Command               | Action                                                |
| --------------------- | ----------------------------------------------------- |
| `..`                  | Go up one directory                                   |
| `...`                 | Go up two directories                                 |
| `....`                | Go up three directories                               |
| `dev`                 | Jump to `~/Development`                               |
| `fr` / `ba` / `fu`    | Jump to Frontend / Backend / Fullstack project folder |
| `fig` / `ar` / `de`   | Jump to Figma / Archive / Dev folders                 |
| `des` / `doc` / `dow` | Jump to Desktop / Documents / Downloads               |

---

### 📦 NPM & Bun Commands

| Alias  | Expands To           |
| ------ | -------------------- |
| `ni`   | `npm install`        |
| `nid`  | `npm install -D`     |
| `nr`   | `npm run`            |
| `nrd`  | `npm run dev`        |
| `nrb`  | `npm run build`      |
| `nrs`  | `npm run start`      |
| `bi`   | `bun install`        |
| `br`   | `bun run`            |
| `brd`  | `bun run dev`        |
| `brb`  | `bun run build`      |
| `brs`  | `bun run start`      |
| `html` | `bun run index.html` |

---

### 🌿 Git Version Control

| Command                 | Description                                    |
| ----------------------- | ---------------------------------------------- |
| `gi`                    | Initialize new git repository                  |
| `gs`                    | Git status (short format)                      |
| `ga`                    | Stage all files (`git add .`)                  |
| `gcm "msg"`             | Commit with message                            |
| `gps` / `gpl`           | Push / Pull from remote                        |
| `gl`                    | Pretty git log with graph                      |
| `gco <branch>`          | Checkout branch                                |
| `gcb <name>`            | Create & checkout new branch                   |
| `gd`                    | View diff                                      |
| `gst` / `gsta` / `gpop` | Stash / Apply stash / Pop stash                |
| `gwip "msg"`            | Quick WIP commit + auto push to current branch |

#### `gwip` — Smart WIP Pusher

```bash
gwip                         # Prompts for message, falls back to "Work in progress (Save Point)"
gwip "add auth middleware"   # Custom message
```

---

### 🔧 Project Initialization

| Command | Description                                                                      |
| ------- | -------------------------------------------------------------------------------- |
| `init`  | Interactive project init — choose Bun or NPM, auto-creates `.gitignore`          |
| `next`  | Scaffold Next.js app (`create-next-app`) via Bun or NPM                          |
| `vite`  | Scaffold Vite project with optional Tailwind CSS v4 setup                        |
| `ui`    | Install & init Shadcn/UI with optional component selection                       |
| `css`   | Auto-detect package manager and install Tailwind CSS + `clsx` + `tailwind-merge` |
| `run`   | Interactive JS/TS file runner via Bun                                            |
| `pg`    | Generate `package.json` for current project                                      |

#### `vite` example flow:

```bash
vite
# ⚡ Setup Vite with:
# 1) Bun  2) NPM
# Add Tailwind CSS v4? (y/n): y
# → Installs packages, creates src/index.css with @import "tailwindcss"
```

---

### ⚙️ System & Maintenance

| Command     | Description                                                                                          |
| ----------- | ---------------------------------------------------------------------------------------------------- |
| `uup`       | **Mega Updater** — interactive fzf menu: OS core, Snap, Flatpak, Bun, Node.js, NPM, deep clean       |
| `uu`        | **Universal Uninstaller** — fuzzy search across apt/snap/flatpak/AppImage, shows size & install date |
| `uc`        | Universal system clean (cache, orphans, logs)                                                        |
| `update`    | Update system packages                                                                               |
| `clean`     | Clean apt cache & remove orphaned packages                                                           |
| `setuppc`   | Bootstrap a new PC with all essential developer tools                                                |
| `rt`        | Install Node.js (via nvm), Bun, and Deno                                                             |
| `ut`        | Setup optimized CLI tooling for the PC                                                               |
| `rel`       | Reload `.bashrc` configuration                                                                       |
| `myip`      | Show your public IP address                                                                          |
| `iploc`     | Show IP + city/region/org info via `ipinfo.io`                                                       |
| `ports`     | List all open ports                                                                                  |
| `kp <port>` | Kill the process running on a given port                                                             |
| `serve`     | Start a local Python HTTP server in current directory                                                |
| `rn`        | Rename all files — removes special characters (`@`, `%`, `*`, `#`)                                   |

#### `uup` — Interactive Mega Updater

```bash
uup
# Opens fzf menu:
# 0. ALL_MAINTENANCE_TASKS
# 1. Core_System_Update
# 2. Snap_Package_Refresh
# 3. Flatpak_Cleanup_Update
# 4. Bun_Runtime_Upgrade
# 5. Node.js_LTS_Sync
# 6. Global_NPM_Update
# 7. Full_System_Deep_Clean
```

#### `uu` — Universal Uninstaller

```bash
uu
# Opens fzf picker with all installed apps (apt + snap + flatpak + AppImage)
# Columns: IDX | NAME | SOURCE | VERSION | SIZE | INSTALL DATE
# TAB to multi-select, ENTER to purge with animated progress bar
# Automatically runs turbo-clean after removal
```

---

### 🔨 Utility Tools

| Command        | Description                                      | Example             |
| -------------- | ------------------------------------------------ | ------------------- |
| `mkd <name>`   | Create directory and `cd` into it                | `mkd my-app`        |
| `rmd <name>`   | Force remove directory recursively               | `rmd old-build`     |
| `rmf <file>`   | Safely remove a file                             | `rmf config.bak`    |
| `bak <file>`   | Create a `.bak` backup copy                      | `bak .env`          |
| `trash <file>` | Move file to system trash (safe delete)          | `trash temp.log`    |
| `ex <archive>` | Extract any archive format                       | `ex project.tar.gz` |
| `ff <name>`    | Find file by name (skips `node_modules`, `.git`) | `ff tsconfig`       |
| `gen <len>`    | Generate a cryptographically secure secret key   | `gen 32`            |
| `h <word>`     | Search command history                           | `h docker`          |
| `to`           | Open current directory in VS Code                |                     |
| `v`            | Play video in terminal                           |                     |
| `c` / `cls`    | Clear the terminal screen                        |                     |

#### Archive formats supported by `ex`:

`.tar.bz2` · `.tar.gz` · `.bz2` · `.rar` · `.gz` · `.tar` · `.zip` · `.7z`

---

## 🏗️ Project Structure

```
fancybash/
├── install.sh          # Bash installer with spinner & backup
├── install.zsh         # Zsh installer with spinner & backup
├── install.ps1         # PowerShell installer with backup & profile integration
├── config.sh           # Bash configuration, aliases, prompt, colors
├── config.zsh          # Zsh configuration, aliases, prompt, colors
├── config.ps1          # PowerShell configuration, aliases, prompt, colors
├── web/
│   ├── index.html      # Landing page (fancybash.netlify.app)
│   ├── style.css       # Design system & responsive styles
│   ├── main.js         # Interactive tabs, animations, copy buttons
│   ├── linux-setup.html# Linux App Ecosystem page
│   ├── linux-setup.css # Linux App Ecosystem styles
│   ├── linux-setup.js  # Linux App Ecosystem logic
│   └── linux-setup-README.md
├── zed/
│   └── install-settings.sh  # Zed IDE settings installer (Flatpak + native)
├── README.md           # You are here
└── LICENSE             # MIT — free to use, fork, and modify
```

### How the installer works

```
install.sh
├── check_deps()           # Verifies curl & grep are present
├── check existing install # Exits early if already installed (idempotent)
├── backup .bashrc         # Creates ~/.bashrc.backup.YYYYMMDD_HHMMSS
├── spinner()              # Animated download progress
├── download config.sh     # Fetched from GitHub Gist
├── validate response      # Guards against HTML error pages
├── append to .bashrc      # Wrapped in >>> / <<< markers
└── source ~/.bashrc       # Auto-reloads the shell
```

---

## 🖥️ Zed IDE Settings

Install a fully-configured `settings.json` for the [Zed](https://zed.dev) editor — works for both the **Flatpak** and **native** installations in one shot.

### One-Line Install

```bash
bash <(curl -fsSL https://gist.githubusercontent.com/rihadjahanopu/bb56371f87793c21a8fad4e4b9815a9b/raw/install-settings.sh)
```

The script will:

1. 💾 **Back up** any existing `settings.json` with a timestamp
2. ✍️ **Write** the new config to both paths:
   - `~/.var/app/dev.zed.Zed/config/zed/settings.json` _(Flatpak)_
   - `~/.config/zed/settings.json` _(native)_
3. ✅ Print a confirmation for each path

> **Restart Zed** after running the script for all settings to take effect.

### What's included

| Setting            | Value                                                      |
| ------------------ | ---------------------------------------------------------- |
| Theme              | `BlackFox` (dark) / `Everforest Light Hard` (light)        |
| Buffer Font        | `Cascadia Code` 22px (fallback: JetBrains Mono, Fira Code) |
| UI Font            | `JetBrains Mono` 20px                                      |
| Terminal Font      | `JetBrains Mono` 22px + `FiraCode Nerd Font` fallback      |
| Tab Size           | `2` spaces                                                 |
| Soft Wrap          | `editor_width`                                             |
| Autosave           | `on_focus_change`                                          |
| Keymap             | `VSCode`                                                   |
| Inlay Hints        | Enabled with background                                    |
| Inline Diagnostics | Enabled                                                    |
| Minimap            | `auto`                                                     |
| Prettier           | Allowed                                                    |
| Git Inline Blame   | With commit summary                                        |

---

## 🐧 Linux App Ecosystem

A curated list of essential applications for a Linux development and creative environment.

This project provides a clean, searchable, and filterable web interface to discover and browse recommended Linux applications. It includes categories for Creative Applications, IDEs, Browsers, System Tools, and Dev Tools. 

**Features:**
- **Searchable Interface:** Instantly search for applications by name, category, or format.
- **Dynamic Filters:** Filter applications by categories like Creative, Development IDE, Browser, Dev Tools, and Tools.
- **Package Formats:** Displays the recommended package format (Flatpak, DEB, etc.) for each application with color-coded badges.

This page has been integrated into the main `fancybash` website and can be accessed via the **Linux Apps** link in the navigation menu.

<details>
<summary><b>View the full list of recommended apps</b></summary>

### 🎨 Creative Applications
| Application | Format | Description |
|---|---|---|
| **Flatseal** | Flatpak | Flatpak App Managed Software |
| **ytDownloader** | Flatpak | Video Downloader Software |
| **Packet** | Flatpak | Quick share for Linux |
| **Inkscape** | Flatpak | Vector Image Editor |
| **VLC** | Flatpak | Video Player Software |
| **Upscayl** | Flatpak | Image Upscaling Software |
| **Pinta** | Flatpak | General Image Editor |
| **Discord** | Flatpak | Social Media & Voice Chat |
| **Pods** | Flatpak | Containers Manager |
| **HandBrake** | Flatpak | Video Compressor |
| **OBS Studio** | Flatpak | Video Recorder & Streamer |
| **Valot** | Flatpak | Note & Task tracking with alarm |
| **Collector** | Flatpak | Drag and drop everything in one place |
| **Gitte** | Flatpak | Git Client Desktop Software |
| **Kdenlive** | Flatpak | Video Editor Software |
| **Bazaar** | Flatpak | App store for Flatpak Applications |
| **Akizip** | Flatpak | Archive Manager (7z, ZIP, TAR) |
| **BudsLink** | Flatpak | Air buds Control for Linux |
| **Emojify** | Flatpak | Emoji finder |
| **Xournal++** | Flatpak | Digital notebook / PDF Annotator |
| **Drawy** | Flatpak | Draw notebook |
| **Gradia** | Flatpak | Screenshot Utility |
| **Scribus** | Flatpak | Vector Image Print / Desktop Publishing |

### 💻 Development IDEs
| Application | Format | Description |
|---|---|---|
| **VS Code** | DEB | Powerful code editor by Microsoft |
| **Qoder** | DEB | Code Editor |
| **Antigravity** | DEV | Advanced Agentic Coding Environment |
| **Zed** | Flatpak | High-performance multiplayer code editor |
| **VSCodium** | Flatpak | Telemetry-free VS Code build |

### 🌐 Browsers
| Application | Format | Description |
|---|---|---|
| **Chrome** | DEB | Google Web Browser |
| **Brave** | Flatpak | Privacy-focused Web Browser |

### 🛠️ System Tools & Utilities
| Application | Format | Category |
|---|---|---|
| **rEFInd** | DEB | Dual boot Manager |
| **Zram** | DEB | Memory compression in RAM |
| **Fzf** | DEB | Command-line fuzzy finder |
| **ls-sensor**| DEB | Hardware sensor monitoring |
| **Git** | DEB | Version Control System |
| **Node.js** | DEB | JavaScript Runtime |
| **Bun** | DEB | Fast JavaScript Runtime |
| **curl** | DEB | Network Data Transfer |
| **wget** | DEB | Network File Retrieval |

</details>

---

## 🤝 Contributing

Contributions are welcome! Whether it's a new alias, a bug fix, or a feature idea:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feat/my-feature`
3. **Commit** your changes: `gcm "feat: add my feature"` _(or regular `git commit`)_
4. **Push** and open a **Pull Request**

Please keep functions focused, well-commented, and compatible with **Bash 4+**.

---

## 📄 License

MIT © [Rihad Jahan Opu](https://github.com/rihadjahanopu)

---

<div align="center">

**If fancybash saves you time daily, give it a ⭐ — it helps others find it!**

<br>

Made with ❤️ in Bangladesh

[![Website](https://img.shields.io/badge/Website-fancybash.netlify.app-22d3ee?style=for-the-badge&logo=netlify&logoColor=white)](https://fancybash.netlify.app)
[![GitHub](https://img.shields.io/badge/GitHub-rihadjahanopu-181717?style=for-the-badge&logo=github)](https://github.com/rihadjahanopu)

© 2026 Rihad Jahan Opu. All rights reserved.

</div>
