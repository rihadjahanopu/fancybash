

<div align="center">

<h1>fancybash ⚡</h1>

Open-source, Beautiful, super-fast, safe & minimal Bash setup — made for modern developers<br>
(Node.js • Bun • clean prompt • zero drama)

[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Shell](https://img.shields.io/badge/Shell-100%25-informational)
![Stars](https://img.shields.io/github/stars/rihadjahanopu/ohmybash?style=social)

</div>

<p align="center">
  <img src="https://i.postimg.cc/pXB6h98T/terminal2.png" alt="Terminal prompt example 1" width="80%">
  <br><br>
  <img src="https://i.postimg.cc/tCzMZ1P1/terminal1.png" alt="Terminal prompt example 2" width="80%">
</p>

### ✨ Why you'll love it

- ⚡ **Lightning fast** — no heavy plugins, minimal git parsing
- 🛡️ **100% safe** — never overwrites your existing `.bashrc` blindly
- 🌈 **Modern & clean prompt** — git branch shown only in repos
- 🟩 **Node.js + Bun first-class citizen** — great aliases out of the box
- 🔧 **One file to rule them all** — customize everything in `config.sh`
- 📦 **Truly one-line install** — no manual cloning needed

<br>

## 🚀 One-Line Installation

Run this in your terminal:

One-line install custom bashrc setup with safe config (Node, Bun friendly).

## 🚀 Install

```bash
bash <(curl -fsSL https://gist.githubusercontent.com/rihadjahanopu/a1c286e48b3ecee1a207c759279e352c/raw/install.sh)
```
## Uninstall
```bash
sed -i '/# >>> fancy-bashrc >>>/,/# <<< fancy-bashrc <<</d' ~/.bashrc && source ~/.bashrc
```

```
ohmybash/
├── install.sh      # The magic installer (safe & idempotent)
├── config.sh       # All aliases, prompt style, PATH, colors — edit this!
├── README.md       # ← You are here
└── LICENSE         # MIT — use it freely
```

## Emoji Font Install

```bash
sudo apt install fonts-noto-color-emoji
```
## font Family Install

```bash
sudo apt install fonts-firacode
```
## Config File Open

```bash
sudo nano /etc/fonts/local.conf
```
## Past Config Code

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>monospace</family>
    <prefer>
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
## Font Cache Relode

```bash
fc-cache -fv

```
## Terminal Font Chack (Optional)

```bash
echo -e "LANG=en_US.UTF-8\nLC_ALL=en_US.UTF-8\nLANGUAGE=en_US" | sudo tee /etc/default/locale
```
## Terminal Font Update For English

```bash

sudo locale-gen en_US.UTF-8
sudo update-locale
```
## Syestem Reboot

```bash
reboot
```




That's all — back to your previous setup.


<p align="center">
Made with ❤️ in Bangladesh by Rihad Jahan Opu
</p>
<p align="center">
If you use it daily — give it a ⭐ to help others find it!
</p>
