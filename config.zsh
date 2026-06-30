
# ==============================================================================
#   ULTRA-THIN COMPACT PRO Zsh ENVIRONMENT
#   Author: [Rihad Jahan Opu]
#   Version: 1.0.1 Complete Multi-Distro Edition
#   Purpose: A fast, beautiful, and productive terminal for Web Development
#   Supports: Ubuntu/Debian, Fedora/RHEL/CentOS, Arch, macOS, Alpine, openSUSE
#   Verified: 2026 - Cross-platform compatibility
# ==============================================================================

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

setopt PROMPT_SUBST


# ======================================================
# 🎨 RAINBOW COLOR & EMOJI SETUP (zsh compatible)
# ======================================================

# ======================================================
# 🌀 CONFIGS & ARRAYS (Zsh Pure Native Fix)
# ======================================================
typeset -g -a rainbow_colors
rainbow_colors=(31 32 33 34 35 36 91 92 93 94 95 96)

rand_color() {
  local idx=$(( (RANDOM % ${#rainbow_colors}) + 1 ))
  echo "${rainbow_colors[$idx]}"
}

rand_emoji() {
  local folder=$(basename "$PWD")
  case $folder in
    *web* )   echo "🌐" ;;
    *node* )  echo "🟢" ;;
    *bun* )   echo "🥐" ;;
    *py* )    echo "🐍" ;;
    *proj* )  echo "💻" ;;
    * )
        local -a emojis
        emojis=(🔥 ⚡️ 🚀 💫 🌈 🌀 ✨ 🧠)
        local idx=$(( (RANDOM % ${#emojis}) + 1 ))
        echo "${emojis[$idx]}" ;;
  esac
}

# ======================================================
# HELPERS
# ======================================================
parse_git_branch() {
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
  local dirty=""
  [[ -n $(git status --porcelain 2>/dev/null) ]] && dirty=" ❗"
  echo " [🌿 $branch$dirty]"
}

node_version() { command -v node >/dev/null 2>&1 && echo "🟢 $(node -v) │ "; }
npm_version() { command -v npm >/dev/null 2>&1 && echo "📦 $(npm -v) │ "; }
bun_version()  { command -v bun  >/dev/null 2>&1 && echo "🥐 $(bun -v) │ "; }
time_date() { echo "📅 $(date +'%b %d')"; }

sys_info() {
  if command -v free >/dev/null 2>&1; then
    local RAM=$(free -h 2>/dev/null | awk '/^Mem/ {print $3 "/" $2}')
    echo "📟 🧠 ${RAM} │ "
  fi
}

battery_info() {
  if [[ -f /sys/class/power_supply/BAT0/capacity ]]; then
    echo "🔋$(cat /sys/class/power_supply/BAT0/capacity)% │ "
  elif [[ -f /sys/class/power_supply/BAT1/capacity ]]; then
    echo "🔋$(cat /sys/class/power_supply/BAT1/capacity)% │ "
  fi
}

kernel_version() { echo "🐧 $(uname -r | cut -d'-' -f1) │ "; }

cpu_temp() {
  if command -v sensors >/dev/null 2>&1; then
    local temp=$(sensors 2>/dev/null | grep -iE 'Package id 0|Core 0|temp1' | head -n1 | grep -oP '\+\K[0-9.]+' | head -n1 | cut -d. -f1)
    [[ -n "$temp" ]] && echo " 🌡️ ${temp}°C"
  fi
}

folder_size() {
  local size=$(du -sh . 2>/dev/null | cut -f1)
  [[ -n "$size" ]] && echo " 📂 ${size}"
}

disk_usage() {
  local disk=$(df -h / 2>/dev/null | awk 'NR==2 {print $4}')
  [[ -n "$disk" ]] && echo " 💽 ${disk} free"
}

load_avg() {
  local load=$(uptime 2>/dev/null | awk -F'load average:' '{ print $2 }' | cut -d',' -f1 | sed 's/ //g')
  [[ -n "$load" ]] && echo " ⚖️ ${load}"
}

typeset -g timer
zsh_stats_preexec() { timer=$SECONDS; }
zsh_stats_precmd() {
  if [ -n "$timer" ]; then
    local delta=$(( SECONDS - timer ))
    [ $delta -ge 1 ] && export CMD_DURATION=" ⏱️ ${delta}s" || export CMD_DURATION=""
    unset timer
  else
    export CMD_DURATION=""
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook preexec zsh_stats_preexec
add-zsh-hook precmd zsh_stats_precmd

check_readonly() { [ ! -w . ] && echo " 🔒"; }
pending_updates() {
  local updates=0
  if command -v checkupdates >/dev/null 2>&1; then
    updates=$(checkupdates 2>/dev/null | wc -l)
  fi
  [[ -n "$updates" && "$updates" -gt 0 ]] && echo " 🆙 $updates"
}

# ======================================================
# 🎯 zsh PROMPT (With Your Original Comments & Absolute Fix)
# ======================================================


# ডাইনামিক প্রোম্পট ইভালুয়েশন অন করা
setopt prompt_subst

build_prompt() {
  local col=$(rand_color)

  # প্রথম লাইন: %F{...}%1~%f ব্যবহার করা হলো যা ব্র্যাকেটের ঝামেলা ১০০% দূর করবে
  #PROMPT="$(rand_emoji) %F{$col}%1~%f $(folder_size)$(parse_git_branch)$(cpu_temp)$(disk_usage)$(load_avg)\$CMD_DURATION$(check_readonly)$(pending_updates)"$'\n'

  # দ্বিতীয় লাইন: ডেভ ও সিস্টেম এনভায়রনমেন্ট
  #PROMPT+="$(node_version)$(npm_version)$(bun_version)$(kernel_version)$(sys_info)$(battery_info)$(time_date)"$'\n'

  PROMPT="$(rand_emoji) %F{$col}%1~%f "$'\n'

  # তৃতীয় লাইন: ব্লিন্কিং কার্সার

  PROMPT+=$'%{\e[5m%}❯❯❯%{\e[25m%} '
}

# প্রতিবার প্রম্পট রিলোডের জন্য হুক অ্যাসাইন
add-zsh-hook precmd build_prompt


# ======================================================
#  ⚡ INTERACTIVE SETUP SCRIPTS
# ======================================================

# --- Initialize a Project (Bun or NPM) ---
in() {
  local has_bun=0 has_npm=0
  command -v bun >/dev/null 2>&1 && has_bun=1
  command -v npm >/dev/null 2>&1 && has_npm=1

  echo "🚀 Select Package Manager:"
  [[ $has_bun -eq 1 ]] && echo "1) 🥐 Bun (Fast)" || echo "1) 🥐 Bun (Not installed)"
  [[ $has_npm -eq 1 ]] && echo "2) 📦 NPM (Standard)" || echo "2) 📦 NPM (Not installed)"

  # ✅ Zsh compatible
  read "choice?Enter choice [1/2]: "

  case "$choice" in
    1)
      [[ $has_bun -eq 0 ]] && { echo "❌ Bun not installed."; return 1; }
      bun init -y
      ;;
    2)
      [[ $has_npm -eq 0 ]] && { echo "❌ NPM not installed."; return 1; }
      npm init -y
      ;;
    *) echo "❌ Cancelled."; return 1 ;;
  esac

  if [ ! -f .gitignore ]; then
    cat > .gitignore << 'GITIGNORE'
# See https://help.github.com/articles/ignoring-files/ for more about ignoring files.

# Dependency directories
node_modules/
jspm_packages/
web_modules/
/.pnp
.pnp.*
.yarn/*
!.yarn/patches
!.yarn/plugins
!.yarn/releases
!.yarn/versions

# Debug logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
lerna-debug.log*

# Diagnostic reports (https://nodejs.org/api/report.html)
report.[0-9]*.[0-9]*.[0-9]*.[0-9]*.json

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Directory for instrumented libs generated by jscoverage/JSCover or coveralls
lib-cov
coverage
.nyc_output

# Grunt intermediate storage (https://gruntjs.com/creating-plugins#storing-task-files)
.grunt

# Bower dependency directory (https://bower.io/)
bower_components

# node-gyp's directory when local npm dependencies are compiled
build/Release

# Dependency directories for instrumented code
.lock-wscript

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Optional stylelint cache
.stylelintcache

# Microbundle cache
.rpt2_cache/
.rts2_cache_cjs/
.rts2_cache_es/
.rts2_cache_umd/

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variable files
.env
.env.development.local
.env.test.local
.env.production.local
.env.local

# parcel-bundler cache (https://parceljs.org/)
.cache
.parcel-cache

# Next.js build images and page cache
.next
out

# Nuxt.js build project
.nuxt
dist

# Gatsby files
.cache/
public

# vuepress build output
.vuepress/dist

# Serverless Webpack directories
.webpack/

# Service stability presets
.svelte-kit

# IDEs and editors
.idea/
.vscode/
*.suo
*.ntvs*
*.njsproj
*.sln
*.sw?

# OS-specific files
.DS_Store
.DS_Store?
._*
Thumbs.db
ehthumbs.db
desktop.ini



# testing
/coverage

# next.js
/.next/
/out/

# production
/build

# misc
.DS_Store
*.pem

# debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.pnpm-debug.log*

# env files (can opt-in for committing if needed)
.env*

# vercel
.vercel

# typescript
*.tsbuildinfo
next-env.d.ts

GITIGNORE
    echo "✅ .gitignore created."
  else
    echo "ℹ️  .gitignore already exists."
  fi

  echo "✅ Project initialized!"
}


# --- Setup Next.js Project ---
function next() {
  echo "⚡ Setup Next.js with:"
  echo "1) Bun"
  echo "2) NPM"
  vared -p "Choice: " -c c
  case "$c" in
    1) bunx create-next-app@latest . ;;
    2) npx create-next-app@latest . ;;
    *) echo "Invalid choice" ;;
  esac
}

# --- Setup Vite shadcn ui ---

# Auto-patch tsconfig/jsconfig with baseUrl and @/* paths
# Priority: tsconfig.app.json (Vite TS) → tsconfig.json (Next.js TS) → jsconfig.json (JS)
_ui_patch_tsconfig() {
  local tsconfig

  if [[ -f "tsconfig.app.json" ]]; then
    tsconfig="tsconfig.app.json"
    echo "  ℹ️  Vite (TS) detected → patching tsconfig.app.json"

  elif [[ -f "tsconfig.json" ]]; then
    tsconfig="tsconfig.json"
    echo "  ℹ️  TypeScript project → patching tsconfig.json"

  elif [[ -f "jsconfig.json" ]]; then
    tsconfig="jsconfig.json"
    echo "  ℹ️  JavaScript project → patching jsconfig.json"

  else
    # No config file found — check if JS project and create jsconfig.json
    if [[ -f "package.json" ]] && ! grep -q '"typescript"' package.json 2>/dev/null; then
      echo "  📝 JavaScript project detected — creating jsconfig.json with @/* alias..."
      node -e "
        const fs = require('fs');
        const jsconfig = {
          compilerOptions: {
            baseUrl: '.',
            paths: { '@/*': ['./src/*'] }
          }
        };
        fs.writeFileSync('jsconfig.json', JSON.stringify(jsconfig, null, 2));
        console.log('  → jsconfig.json created with @/* alias');
      "
      return
    else
      echo "⚠️  No tsconfig/jsconfig found, skipping..."
      return
    fi
  fi

  # Check if paths already set
  if grep -q '"@/\*"' "$tsconfig"; then
    echo "  ✅ $tsconfig paths already configured."
    return
  fi

  echo "🔧 Patching $tsconfig with baseUrl & @/* paths..."

  # Use node to safely patch JSON
  node -e "
    const fs = require('fs');
    const raw = fs.readFileSync('$tsconfig', 'utf8');
    const json = JSON.parse(raw);
    if (!json.compilerOptions) json.compilerOptions = {};
    json.compilerOptions.baseUrl = '.';
    json.compilerOptions.paths = { '@/*': ['./src/*'] };
    fs.writeFileSync('$tsconfig', JSON.stringify(json, null, 2));
    console.log('  → baseUrl & paths written to ' + '$tsconfig');
  "
}

# Auto-patch vite.config.ts with path alias and tailwind import
_ui_patch_viteconfig() {
  local viteconfig
  viteconfig=$(ls vite.config.ts vite.config.js 2>/dev/null | head -n1)

  if [[ -z "$viteconfig" ]]; then
    echo "⚠️  vite.config.ts/js not found, skipping..."
    return
  fi

  echo "🔧 Patching $viteconfig with path alias & tailwind..."

  local content
  content=$(cat "$viteconfig")

  # Add: import path from "path"
  if ! echo "$content" | grep -q 'import path from'; then
    sed -i '1s|^|import path from "path"\n|' "$viteconfig"
    echo "  → Added: import path from \"path\""
  else
    echo "  ✅ path import already exists."
  fi

  # Add: import tailwindcss from "@tailwindcss/vite"
  if ! grep -q '@tailwindcss/vite' "$viteconfig"; then
    sed -i '1s|^|import tailwindcss from "@tailwindcss/vite"\n|' "$viteconfig"
    echo "  → Added: import tailwindcss from \"@tailwindcss/vite\""
  else
    echo "  ✅ tailwindcss import already exists."
  fi

  # Add tailwindcss() to plugins array if missing
  if ! grep -q 'tailwindcss()' "$viteconfig"; then
    sed -i 's/plugins: \[/plugins: [tailwindcss(), /' "$viteconfig"
    echo "  → Added: tailwindcss() to plugins"
  else
    echo "  ✅ tailwindcss() plugin already exists."
  fi

  # Add resolve.alias if missing (no leading comma — JS syntax fix)
  if ! grep -q '"@"' "$viteconfig" && ! grep -q "@:" "$viteconfig"; then
    # Insert resolve block before closing }) of defineConfig
    sed -i '/^})/i\  resolve: {\n    alias: {\n      "@": path.resolve(__dirname, "./src"),\n    },\n  }' "$viteconfig"
    echo "  → Added: resolve.alias @/* → ./src"
  else
    echo "  ✅ resolve.alias already exists."
  fi
}

ui() {
  echo "🎨 Setup Shadcn UI"
  echo ""

  # Auto-detect project type
  local project_type
  if [[ -f "tsconfig.app.json" ]]; then
    project_type="vite"
    echo "  🔍 Detected: Vite project"
  elif [[ -f "next.config.js" || -f "next.config.ts" || -f "next.config.mjs" ]]; then
    project_type="nextjs"
    echo "  🔍 Detected: Next.js project"
  elif grep -q '"next"' package.json 2>/dev/null; then
    project_type="nextjs"
    echo "  🔍 Detected: Next.js project (via package.json)"
  else
    echo "  ⚠️  Could not auto-detect project type."
    echo "  1) Vite (React)"
    echo "  2) Next.js"
    read "pt?Choose manually: "
    case "$pt" in
      1) project_type="vite" ;;
      2) project_type="nextjs" ;;
      *) echo "Invalid choice"; return ;;
    esac
  fi

  echo ""
  echo "Package manager:"
  echo "1) Bun"
  echo "2) NPM"
  read "pm?Choice: "

  read "components?Add specific components? (e.g. button card input): "

  # STEP 1: Patch tsconfig FIRST — shadcn init requires @/* path alias
  echo ""
  echo "⚙️  Pre-configuring path aliases before shadcn init..."
  _ui_patch_tsconfig

  if [[ "$project_type" == "vite" ]]; then
    case "$pm" in
      1)
        echo ""
        echo "🧱 Initializing Shadcn UI with Bun (Vite)..."
        bunx --bun shadcn@latest init -t vite
        if [[ -n "$components" ]]; then
          echo "🔘 Adding components: $components..."
          bunx --bun shadcn@latest add $components
        else
          echo "🔘 Adding default Button component..."
          bunx --bun shadcn@latest add button
        fi
        ;;
      2)
        echo ""
        echo "🧱 Initializing Shadcn UI with NPM (Vite)..."
        npx shadcn@latest init -t vite
        if [[ -n "$components" ]]; then
          echo "🔘 Adding components: $components..."
          npx shadcn@latest add $components
        else
          echo "🔘 Adding default Button component..."
          npx shadcn@latest add button
        fi
        ;;
      *) echo "Invalid package manager choice"; return ;;
    esac

    # STEP 2: Patch vite.config only for Vite projects
    echo ""
    echo "⚙️  Patching vite.config with alias & tailwind..."
    _ui_patch_viteconfig

  elif [[ "$project_type" == "nextjs" ]]; then
    case "$pm" in
      1)
        echo ""
        echo "🧱 Initializing Shadcn UI with Bun (Next.js)..."
        bunx --bun shadcn@latest init
        if [[ -n "$components" ]]; then
          echo "🔘 Adding components: $components..."
          bunx --bun shadcn@latest add $components
        else
          echo "🔘 Adding default Button component..."
          bunx --bun shadcn@latest add button
        fi
        ;;
      2)
        echo ""
        echo "🧱 Initializing Shadcn UI with NPM (Next.js)..."
        npx shadcn@latest init
        if [[ -n "$components" ]]; then
          echo "🔘 Adding components: $components..."
          npx shadcn@latest add $components
        else
          echo "🔘 Adding default Button component..."
          npx shadcn@latest add button
        fi
        ;;
      *) echo "Invalid package manager choice"; return ;;
    esac
    echo "  ℹ️  Next.js detected — vite.config patch skipped."
  fi

  echo ""
  echo "---------------------------------------------------"
  echo "✅ Shadcn UI setup complete!"
  echo "🚀 Happy coding with Shadcn!"
  echo "---------------------------------------------------"
}


# --- Setup Vite (React/Vue) Project ---
vite() {
  echo "⚡ Setup Vite with:"
  echo "1) Bun"
  echo "2) NPM"
  read "c?Choice: "

  read "tw?Add Tailwind CSS v4? (y/n): "

  case "$c" in
    1)
      bunx create-vite@latest .
      if [[ "$tw" == "y" ]]; then
        if ! bun add tailwindcss @tailwindcss/vite; then
          echo "❌ Install failed with Bun."
          read "force?Try with --force? (y/n): "
          [[ "$force" == "y" ]] && bun add tailwindcss @tailwindcss/vite --force
        fi
      fi
      ;;
    2)
      npx create-vite@latest .
      if [[ "$tw" == "y" ]]; then
        if ! npm install tailwindcss @tailwindcss/vite; then
          echo "❌ Install failed with NPM (Peer Dependency Conflict likely)."
          read "legacy?Try with --legacy-peer-deps? (y/n): "
          [[ "$legacy" == "y" ]] && npm install tailwindcss @tailwindcss/vite --legacy-peer-deps
        fi
      fi
      ;;
    *) echo "Invalid choice"; return ;;
  esac

  if [[ "$tw" == "y" ]]; then
    mkdir -p src
    CSS_FILE="src/index.css"
    [ -f "src/style.css" ] && CSS_FILE="src/style.css"

    echo '@import "tailwindcss";' > "$CSS_FILE"

    # Auto-detect Vite config file
    VITE_CONFIG=""
    for f in "vite.config.ts" "vite.config.js" "vite.config.mjs"; do
      [ -f "$f" ] && VITE_CONFIG="$f" && break
    done

    echo "---------------------------------------------------"
    echo "✅ Tailwind CSS v4 packages installed!"
    echo "✅ Added '@import \"tailwindcss\";' to $CSS_FILE"
    echo ""

    if [[ -n "$VITE_CONFIG" ]]; then
      echo "⚠️  ACTION REQUIRED: Update $VITE_CONFIG"
      echo ""
      echo "Add these lines:"
      echo "  import tailwindcss from '@tailwindcss/vite'"
      echo "  plugins: [tailwindcss(), ...]"
      echo ""
      echo "Or run this command to auto-patch:"
      echo "  sed -i '1i import tailwindcss from \"@tailwindcss/vite\";' $VITE_CONFIG && sed -i 's/plugins: \\[/plugins: [tailwindcss(), /' $VITE_CONFIG"
    else
      echo "⚠️  No vite.config found. Create one and add:"
      echo "  import tailwindcss from '@tailwindcss/vite'"
      echo "  plugins: [tailwindcss()]"
    fi
    echo "---------------------------------------------------"
  fi
}




# ======================================================
# 🚀 Install Tailwind CSS + Helpers
# ======================================================


css() {
  # Check package.json
  if [[ ! -f package.json ]]; then
    echo "❌ Error: package.json not found!"
    return 1
  fi

  # Auto-detect package manager
  local pm="npm"
  [[ -f bun.lockb ]] && pm="bun"

  # Detect project type
  local has_vite=0 has_next=0 has_postcss=0
  [[ -f vite.config.ts || -f vite.config.js ]] && has_vite=1
  [[ -f next.config.ts || -f next.config.js || -f next.config.mjs ]] && has_next=1
  [[ -f postcss.config.js || -f postcss.config.mjs ]] && has_postcss=1

  echo "📦 Installing Tailwind CSS v4 via $pm..."

  if [[ "$pm" == "bun" ]]; then
    if [[ $has_vite -eq 1 ]]; then
      bun add -D tailwindcss @tailwindcss/vite
    else
      bun add -D tailwindcss @tailwindcss/postcss postcss
    fi
    bun add -D clsx tailwind-merge
  else
    if [[ $has_vite -eq 1 ]]; then
      npm install -D tailwindcss @tailwindcss/vite
    else
      npm install -D tailwindcss @tailwindcss/postcss postcss
    fi
    npm install -D clsx tailwind-merge
  fi

  # Find main CSS file
  local css_file=""
  for f in "src/index.css" "src/style.css" "src/app/globals.css" "app/globals.css" "styles/globals.css" "src/styles.css"; do
    [[ -f "$f" ]] && css_file="$f" && break
  done

  # Create or update CSS file
  if [[ -n "$css_file" ]]; then
    if ! grep -q '@import "tailwindcss"' "$css_file" 2>/dev/null; then
      echo '@import "tailwindcss";' | cat - "$css_file" > /tmp/tw_css && mv /tmp/tw_css "$css_file"
      echo "✅ Added @import to $css_file"
    fi
  else
    mkdir -p src
    echo '@import "tailwindcss";' > src/index.css
    echo "✅ Created src/index.css"
    css_file="src/index.css"
  fi

  # Vite config patch (if Vite project)
  if [[ $has_vite -eq 1 ]]; then
    local vite_config=""
    for f in "vite.config.ts" "vite.config.js" "vite.config.mjs"; do
      [[ -f "$f" ]] && vite_config="$f" && break
    done

    if [[ -n "$vite_config" ]] && ! grep -q "@tailwindcss/vite" "$vite_config" 2>/dev/null; then
      sed -i '1i import tailwindcss from "@tailwindcss/vite";' "$vite_config"
      sed -i 's/plugins: \[/plugins: [tailwindcss(), /' "$vite_config"
      echo "✅ Patched $vite_config"
    fi
  fi

  # PostCSS config (if not Vite/Next)
  if [[ $has_vite -eq 0 && $has_next -eq 0 ]]; then
    if [[ ! -f postcss.config.js && ! -f postcss.config.mjs ]]; then
      cat > postcss.config.mjs << 'EOF'
/** @type {import('postcss-load-config').Config} */
const config = {
  plugins: {
    "@tailwindcss/postcss": {},
  },
};

export default config;
EOF
      echo "✅ Created postcss.config.mjs"
    fi
  fi

  echo ""
  echo "🎉 Tailwind CSS v4 Ready!"
  echo "   CSS: $css_file"
  [[ $has_vite -eq 1 ]] && echo "   Plugin: @tailwindcss/vite"
  [[ $has_vite -eq 0 && $has_next -eq 0 ]] && echo "   Plugin: @tailwindcss/postcss"
}




#  Kill Port (Usage: kp 3000)
kp() {
  if [ -z "$1" ]; then echo "❌ Port number required!"; return; fi
  lsof -ti:$1 | xargs kill -9 > /dev/null 2>&1 && echo "✅ Port $1 killed." || echo "❌ Port $1 not in use."
}



# ======================================================
# 🚀 Universal Extractor (Usage: ex file.zip)
# ======================================================


ex() {
  if [ -f "$1" ] ; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"   ;;
      *.tar.gz)    tar xzf "$1"   ;;
      *.bz2)       bunzip2 "$1"   ;;
      *.rar)       unrar x "$1"   ;;
      *.gz)        gunzip "$1"    ;;
      *.tar)       tar xf "$1"    ;;
      *.zip)       unzip "$1"     ;;
      *.7z)        7z x "$1"      ;;
      *)           echo "❌ Extraction error" ;;
    esac
  else
    echo "❌ '$1' is not a valid file"
  fi
}


# Usage: ff filename
ff() {
  find . -type f -iname "*$1*" -not -path "*/node_modules/*" -not -path "*/.git/*"
}

#  Secret Key Generator (Usage: gen 32)
gen() {
  local len="${1:-24}"
  openssl rand -base64 "$len" | cut -c1-"$len"
  echo -e "\n✅ Secret generated!"
}

#  Backup File (Usage: bak .env)
bak() {
  cp "$1" "$1.bak" && echo "✅ Created: $1.bak"
}


# Global IP & Location Details
alias iploc='curl -s ipinfo.io/json | grep -E "ip|city|region|org"'


# Search Command History
# Usage: h git
alias h='history | grep'

# 10. Trash (Safe Delete - moves to system trash)
trash() {
  mv "$@" ~/.local/share/Trash/files/ 2>/dev/null || mv "$@" ~/.Trash/ 2>/dev/null && echo "🗑 Moved to Trash."
}


# ======================================================
# 🚀 INTERACTIVE GIT WIP & PUSH
# ======================================================


gwip() {
    # Color Codes
    local CYAN='\033[1;36m'
    local YELLOW='\033[1;33m'
    local GREEN='\033[0;32m'
    local RED='\033[0;31m'
    local BOLD='\033[1m'
    local NC='\033[0m'

    # ১. সব ফাইল স্টেজ করা
    git add .

    # ২. Header দেখানো
    echo -e "\n${CYAN}🚀 Git Quick Push Mode${NC}"
    echo -e "${CYAN}────────────────────────────${NC}\n"

    # ৩. মেসেজ ইনপুট (zsh-safe way)
    echo -ne "${BOLD}📝 Enter commit message${NC} ${YELLOW}[Enter for default]${NC}: "
    local msg
    read -r msg

    # ৪. মেসেজ সেট করা (খালি থাকলে ডিফল্ট)
    local final_msg="${msg:-Work in progress (Save Point)}"

    # ৫. কমিট করা
    echo -e "\n${CYAN}📦 Committing...${NC}"
    git commit -m "🚧 WIP: $final_msg"

    # ৬. পুশ করা
    echo -e "\n${YELLOW}📤 Pushing to remote...${NC}"
    if git push; then
        echo -e "\n${GREEN}✅ Everything committed and pushed successfully!${NC}"
    else
        echo -e "\n${RED}❌ Push failed! Check your internet or remote settings.${NC}"
        return 1
    fi
}



# ======================================================
#  📦 universal remove
# ======================================================


uu() {
    local RED='\033[1;31m' GRN='\033[1;32m' YLW='\033[1;33m' CYN='\033[1;36m' BOLD='\033[1m' NC='\033[0m'

    # --- OS & Package Manager Detection ---
    local PKG_MGR=""
    if command -v apt-get &>/dev/null; then
        PKG_MGR="apt"
    elif command -v pacman &>/dev/null; then
        PKG_MGR="pacman"
    elif command -v dnf &>/dev/null; then
        PKG_MGR="dnf"
    else
        echo -e "${RED}Unsupported package manager! Cannot proceed.${NC}"
        return 1
    fi

    # --- ZSH FIX: Bulletproof fzf detection ---
    local FZF_CMD=""
    FZF_CMD=$(whence -p fzf 2>/dev/null)
    [[ -z "$FZF_CMD" ]] && FZF_CMD=$(command -v fzf 2>/dev/null)
    [[ -z "$FZF_CMD" ]] && FZF_CMD=$(command -v fzf 2>/dev/null)

    if [[ -z "$FZF_CMD" ]]; then
        local fzf_paths=(
            /usr/bin/fzf
            /usr/local/bin/fzf
            /bin/fzf
            /usr/share/doc/fzf/bin/fzf
            /usr/share/fzf/bin/fzf
            /opt/fzf/bin/fzf
            ~/.fzf/bin/fzf
            "$HOME/.fzf/bin/fzf"
        )
        for p in "${fzf_paths[@]}"; do
            [[ -x "$p" ]] && { FZF_CMD="$p"; break; }
        done
    fi

    if [[ -z "$FZF_CMD" ]]; then
        echo -e "${YLW}fzf is missing. Installing...${NC}"
        case "$PKG_MGR" in
            apt) sudo apt update && sudo apt install -y fzf ;;
            pacman) sudo pacman -Sy --noconfirm fzf ;;
            dnf) sudo dnf install -y fzf ;;
        esac
        rehash 2>/dev/null || true
        FZF_CMD=$(whence -p fzf 2>/dev/null)
        [[ -z "$FZF_CMD" ]] && FZF_CMD=$(command -v fzf 2>/dev/null)
        [[ -z "$FZF_CMD" ]] && FZF_CMD=$(command -v fzf 2>/dev/null)
    fi

    if [[ -z "$FZF_CMD" ]] || [[ ! -x "$FZF_CMD" ]]; then
        echo -e "${RED}fzf installation failed or not in PATH.${NC}"
        return 1
    fi

    echo -e "${GRN}✔ Using fzf: $FZF_CMD${NC}"

    [[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh 2>/dev/null
    [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh 2>/dev/null
    [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh 2>/dev/null

    sudo -v || { echo -e "${RED}Sudo authentication failed.${NC}"; return 1; }

    sync
    local START_KB=$(df -k / | awk 'NR==2 {print $4}')
    local APPS_RAW=""
    local idx=1

    echo -e "${CYN}🔍 Harvesting System Assets...${NC}"

    shred_animation() {
        local PID=$1 pkg=$2
        local i=0 exit_status=0

        # ZSH FIX: inner functions don't inherit outer local variables —
        # define colors locally so printf format works correctly
        local _R="\033[1;31m" _G="\033[1;32m" _C="\033[1;36m" _B="\033[1m" _N="\033[0m"

        # ZSH FIX: use array for spinner so indexing is unambiguous
        local -a sp=('/' '-' '\' '|')
        local BAR_WIDTH=20

        tput civis 2>/dev/null || true

        while kill -0 "$PID" 2>/dev/null; do
            local filled=$(( i % (BAR_WIDTH + 1) ))
            local empty=$(( BAR_WIDTH - filled ))

            # ZSH FIX: Use printf width trick instead of C-style for loops.
            # C-style ((j++)) evaluates to 0 when j reaches the limit,
            # zsh returns exit code 1, and the j counter leaks to stdout.
            local bar="" e_bar=""
            [[ $filled -gt 0 ]] && bar=$(printf '%*s' "$filled" '' | tr ' ' '█')
            [[ $empty  -gt 0 ]] && e_bar=$(printf '%*s' "$empty"  '' | tr ' ' '▒')

            local sc="${sp[$(( (i % 4) + 1 ))]}"

            # \r moves to column 0; no trailing newline so next frame overwrites
            printf "\r${_C}⚡ Processing ${_B}%s${_N}: ${_R}[${_G}%s${_R}%s${_R}]${_N} %s " \
                "$pkg" "$bar" "$e_bar" "$sc"

            # ZSH FIX: avoid ((i++)) which returns exit-code 1 when i==0
            i=$(( i + 1 ))
            sleep 0.1
        done

        wait "$PID" 2>/dev/null
        exit_status=$?

        # Clear the animation line cleanly
        local cols
        cols=$(tput cols 2>/dev/null || echo 80)
        printf "\r%${cols}s\r" ""
        tput cnorm 2>/dev/null || true

        return $exit_status
    }

    format_name() {
        echo "$1" | sed -E 's/(google-chrome-stable|google-chrome)/chrome/g; s/(brave-browser)/brave/g; s/code/vscode/g; s/(-stable|-bin|-desktop)//g; s/\.[a-zA-Z0-9]+$//' | cut -c1-18
    }

    # ============================================
    # --- SNAP COLLECTION (FIXED) ---
    # ============================================
    if command -v snap &>/dev/null; then
        echo -e "${CYN}  → Scanning Snap packages...${NC}"
        local snap_list
        snap_list=$(snap list 2>/dev/null | tail -n +2)
        if [[ -n "$snap_list" ]]; then
            echo "$snap_list" | while read -r line; do
                [[ -z "$line" ]] && continue
                local pkg=$(echo "$line" | awk '{print $1}')
                local ver=$(echo "$line" | awk '{print $2}')
                [[ "$pkg" =~ ^(Name|core|snapd|bare|gtk|gnome|kf5|qt) ]] && continue
                local name=$(format_name "$pkg")
                local size=$(du -sh /var/lib/snapd/snaps/"${pkg}"_*.snap 2>/dev/null | tail -1 | awk '{print $1}')
                local inst_date=$(snap info "$pkg" 2>/dev/null | grep "installed:" | awk '{print $2}')
                APPS_RAW+="$(printf "%-4s | %-18s | %-10s | %-12s | %-8s | %-10s | %s\n" "$idx" "$name" "snap" "$ver" "${size:-N/A}" "${inst_date:-N/A}" "$pkg")"$'\n'
                ((idx++))
            done
        fi
    fi

    # ============================================
    # --- FLATPAK COLLECTION (FIXED) ---
    # ============================================
    if command -v flatpak &>/dev/null; then
        echo -e "${CYN}  → Scanning Flatpak packages...${NC}"
        local flat_list
        flat_list=$(flatpak list --app --columns=application,name,version 2>/dev/null)
        if [[ -n "$flat_list" ]]; then
            echo "$flat_list" | while IFS=$'\t' read -r id name ver; do
                [[ -z "$id" ]] && continue
                local clean_n=$(format_name "$name")
                local fp_path="/var/lib/flatpak/app/$id"
                [[ ! -d "$fp_path" ]] && fp_path="$HOME/.local/share/flatpak/app/$id"
                local size=$(du -sh "$fp_path" 2>/dev/null | awk '{print $1}')
                local inst_date=$(stat -c %y "$fp_path" 2>/dev/null | awk '{print $1}')
                APPS_RAW+="$(printf "%-4s | %-18s | %-10s | %-12s | %-8s | %-10s | %s\n" "$idx" "$clean_n" "flatpak" "$ver" "${size:-~MB}" "$inst_date" "$id")"$'\n'
                ((idx++))
            done
        fi
    fi

    # ============================================
    # --- APPIMAGE COLLECTION (FIXED) ---
    # ============================================
    echo -e "${CYN}  → Scanning AppImage files...${NC}"
    local appimage_paths=(
        "$HOME/Downloads"
        "$HOME/Applications"
        "/opt"
        "$HOME/.local/bin"
        "$HOME/bin"
    )
    local find_paths=""
    for d in "${appimage_paths[@]}"; do
        [[ -d "$d" ]] && find_paths+="$d "
    done

    if [[ -n "$find_paths" ]]; then
        local appimage_list
        appimage_list=$(find $find_paths -maxdepth 3 -name "*.AppImage" -type f 2>/dev/null)
        if [[ -n "$appimage_list" ]]; then
            echo "$appimage_list" | while IFS= read -r path; do
                [[ -z "$path" ]] && continue
                # ZSH FIX: Use ${path:t} instead of basename
                local filename="${path:t}"
                local name=$(format_name "$filename")
                local size=$(du -sh "$path" 2>/dev/null | awk '{print $1}')
                local inst_date=$(stat -c %y "$path" 2>/dev/null | awk '{print $1}')
                APPS_RAW+="$(printf "%-4s | %-18s | %-10s | %-12s | %-8s | %-10s | %s\n" "$idx" "$name" "appimage" "Local" "${size:-N/A}" "${inst_date:-N/A}" "$path")"$'\n'
                ((idx++))
            done
        fi
    fi

    # ============================================
    # --- APT/DEB COLLECTION (FIXED) ---
    # ============================================
    case "$PKG_MGR" in
        apt)
            echo -e "${CYN}  → Scanning APT packages...${NC}"
            local manual_pkgs
            manual_pkgs=$(apt-mark showmanual 2>/dev/null)
            if [[ -n "$manual_pkgs" ]]; then
                # ZSH FIX: Process one by one to avoid word splitting issues
                echo "$manual_pkgs" | while IFS= read -r pkg; do
                    [[ -z "$pkg" ]] && continue
                    [[ "$pkg" =~ ^(linux-|grub|systemd|lib|python|gir1) ]] && continue

                    local ver=$(dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null)
                    [[ -z "$ver" ]] && continue

                    local name=$(format_name "$pkg")
                    local size_kb=$(dpkg-query -W -f='${Installed-Size}' "$pkg" 2>/dev/null)
                    local size="N/A"
                    if [[ -n "$size_kb" && "$size_kb" =~ ^[0-9]+$ ]]; then
                        if (( size_kb >= 1048576 )); then
                            size=$(awk "BEGIN {printf \"%.1fGB\", $size_kb/1048576}")
                        else
                            size=$(awk "BEGIN {printf \"%.1fMB\", $size_kb/1024}")
                        fi
                    fi
                    local inst_date=$(stat -c %y "/var/lib/dpkg/info/${pkg}.list" 2>/dev/null | awk '{print $1}' || echo "N/A")
                    APPS_RAW+="$(printf "%-4s | %-18s | %-10s | %-12s | %-8s | %-10s | %s\n" "$idx" "$name" "apt" "${ver:0:10}" "$size" "$inst_date" "$pkg")"$'\n'
                    ((idx++))
                done
            fi
            ;;
        pacman)
            echo -e "${CYN}  → Scanning Pacman packages...${NC}"
            local pacman_list
            pacman_list=$(pacman -Qe 2>/dev/null)
            if [[ -n "$pacman_list" ]]; then
                echo "$pacman_list" | while IFS=' ' read -r pkg ver; do
                    [[ -z "$pkg" ]] && continue
                    [[ "$pkg" =~ ^(linux|grub|systemd|lib) ]] && continue
                    local name=$(format_name "$pkg")
                    APPS_RAW+="$(printf "%-4s | %-18s | %-10s | %-12s | %-8s | %-10s | %s\n" "$idx" "$name" "pacman" "${ver:0:10}" "N/A" "N/A" "$pkg")"$'\n'
                    ((idx++))
                done
            fi
            ;;
        dnf)
            echo -e "${CYN}  → Scanning DNF packages...${NC}"
            local dnf_list
            dnf_list=$(rpm -qa --qf '%{NAME} %{VERSION}\n' 2>/dev/null)
            if [[ -n "$dnf_list" ]]; then
                echo "$dnf_list" | while IFS=' ' read -r pkg ver; do
                    [[ -z "$pkg" ]] && continue
                    [[ "$pkg" =~ ^(kernel|grub|systemd|lib) ]] && continue
                    local name=$(format_name "$pkg")
                    APPS_RAW+="$(printf "%-4s | %-18s | %-10s | %-12s | %-8s | %-10s | %s\n" "$idx" "$name" "dnf" "${ver:0:10}" "N/A" "N/A" "$pkg")"$'\n'
                    ((idx++))
                done
            fi
            ;;
    esac

    APPS_RAW="${APPS_RAW%$'\n'}"

    # DEBUG: Show count
    local total_apps=$(echo "$APPS_RAW" | grep -c '^[0-9]' 2>/dev/null || echo "0")
    echo -e "${GRN}✔ Found $total_apps applications${NC}"

    [[ -z "$APPS_RAW" ]] && { echo -e "${YLW}No applications found.${NC}"; return; }

    local SELECTED
    SELECTED=$(echo "$APPS_RAW" | "$FZF_CMD" \
        --ansi --multi --layout=reverse --border=rounded \
        --prompt="🎯 Asset Target: " \
        --delimiter=' \| ' --with-nth=1,2,3 \
        --header="$(printf "%-5s %-20s %-11s " "IDX" "NAME" "SOURCE")" \
        --preview-window='right,45%,border-rounded,wrap' \
        --preview='
            RED="\033[1;31m"; GRN="\033[1;32m"; YLW="\033[1;33m"; CYN="\033[1;36m"; BOLD="\033[1m"; NC="\033[0m"
            name=$(echo {2}); src=$(echo {3}); ver=$(echo {4}); size=$(echo {5}); idate=$(echo {6})
            printf "\n ${BOLD}${CYN}┌─ Package Details  ─────────────┐${NC}"
            printf "\n ${CYN}│${NC} ${YLW}%-12s${NC} : %-15s ${CYN}│${NC}" "Name" "$name"
            printf "\n ${CYN}│${NC} ${YLW}%-12s${NC} : %-15s ${CYN}│${NC}" "Source" "$src"
            printf "\n ${CYN}│${NC} ${YLW}%-12s${NC} : %-15s ${CYN}│${NC}" "Version" "$ver"
            printf "\n ${CYN}│${NC} ${YLW}%-12s${NC} : ${RED}%-15s${NC} ${CYN}│${NC}" "Disk Size" "$size"
            printf "\n ${CYN}│${NC} ${YLW}%-12s${NC} : ${GRN}%-15.10s${NC} ${CYN}│${NC}" "Inst. Date" "$idate"
            printf "\n ${CYN}└────────────────────────────────┘${NC}\n"
            printf "\n ${CYN}┌─ Description ────────────────┐${NC}\n"
            printf " ${CYN}│${NC} Managed via %-16s ${CYN}│${NC}\n" "$src"
            printf " ${CYN}│${NC} Total space: ${RED}%-14s${NC} ${CYN} │${NC}\n" "$size"
            printf " ${CYN}└──────────────────────────────┘${NC}\n"
            printf " ${RED} [TAB] Select  [ENTER] Purge ${NC}"
        ')

    [[ -z "$SELECTED" ]] && { echo -e "${YLW}No selection made.${NC}"; return; }

    local count
    count=$(echo "$SELECTED" | wc -l)
    echo -e "\n${YLW}⚠️ You have selected ${BOLD}$count${NC} ${YLW}apps to uninstall:${NC}"
    echo -e "${CYN}┌──────────────────────────────────────────┐${NC}"
    echo "$SELECTED" | awk -F ' \| ' '{printf "│ • %-38s │\n", $2}'
    echo -e "${CYN}└──────────────────────────────────────────┘${NC}"

    echo -n "Are you sure you want to proceed? (y/N): "
    local confirm
    read -r confirm
    [[ ! "$confirm" =~ ^[Yy]$ ]] && { echo -e "${RED}Aborted.${NC}"; return; }
    sudo -v || { echo -e "${RED}Sudo authentication failed.${NC}"; return 1; }

    local OLD_SET="+m"
    [[ $- == *m* ]] && OLD_SET="-m"
    set +m

    local failed_apps=""

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local pkg_display=$(echo "$line" | awk -F ' \| ' '{print $2}' | xargs)
        local src_type=$(echo "$line" | awk -F ' \| ' '{print $3}' | xargs)
        local orig_id=$(echo "$line" | awk -F ' \| ' '{print $7}' | xargs)

        [[ -z "$src_type" || -z "$orig_id" ]] && continue

        (
            local exit_code=0
            case "$src_type" in
                snap)
                    sudo snap remove "$orig_id" &>/dev/null || exit_code=1
                    local snap_name="${orig_id:t}"
                    rm -rf ~/snap/"$snap_name" 2>/dev/null
                    ;;
                flatpak)
                    flatpak uninstall -y --delete-data "$orig_id" &>/dev/null || exit_code=1
                    rm -rf ~/.var/app/"$orig_id" 2>/dev/null
                    rm -rf ~/.local/share/flatpak/app/"$orig_id" 2>/dev/null
                    ;;
                appimage)
                    if [[ -f "$orig_id" ]]; then
                        rm -f "$orig_id" &>/dev/null || exit_code=1
                    else
                        exit_code=1
                    fi
                    local appimage_name="${orig_id:t:r}"
                    [[ -n "$appimage_name" ]] && {
                        rm -f ~/.local/share/applications/appimagekit_*"${appimage_name}"*.desktop 2>/dev/null
                        rm -f ~/.local/share/applications/"${appimage_name}".desktop 2>/dev/null
                        rm -rf ~/.local/share/icons/hicolor/*/apps/appimagekit_*"${appimage_name}"* 2>/dev/null
                        rm -f ~/.config/AppImageLauncher/entries/"${appimage_name}"* 2>/dev/null
                    }
                    ;;
                apt)
                    sudo apt purge -y "$orig_id" &>/dev/null || exit_code=1
                    if [[ "$orig_id" =~ ^[a-z0-9-]+$ ]] && [[ ! "$orig_id" =~ ^(python|lib|systemd|xorg|gtk|gnome|kde|qt) ]]; then
                        [[ -d ~/.config/"$orig_id" ]] && rm -rf ~/.config/"$orig_id" 2>/dev/null
                        [[ -d ~/.cache/"$orig_id" ]] && rm -rf ~/.cache/"$orig_id" 2>/dev/null
                        [[ -d ~/.local/share/"$orig_id" ]] && rm -rf ~/.local/share/"$orig_id" 2>/dev/null
                        local base_name=$(echo "$orig_id" | sed 's/-desktop//g; s/-stable//g; s/-git//g; s/-bin//g')
                        if [[ "$base_name" != "$orig_id" ]]; then
                            [[ -d ~/.config/"$base_name" ]] && rm -rf ~/.config/"$base_name" 2>/dev/null
                            [[ -d ~/.cache/"$base_name" ]] && rm -rf ~/.cache/"$base_name" 2>/dev/null
                            [[ -d ~/.local/share/"$base_name" ]] && rm -rf ~/.local/share/"$base_name" 2>/dev/null
                        fi
                        [[ -d ~/."${base_name}" ]] && rm -rf ~/."${base_name}" 2>/dev/null
                    fi
                    ;;
                pacman)
                    sudo pacman -Rns --noconfirm "$orig_id" &>/dev/null || exit_code=1
                    if [[ "$orig_id" =~ ^[a-z0-9-]+$ ]] && [[ ! "$orig_id" =~ ^(python|lib|systemd|xorg|gtk|gnome|kde|qt) ]]; then
                        [[ -d ~/.config/"$orig_id" ]] && rm -rf ~/.config/"$orig_id" 2>/dev/null
                        [[ -d ~/.cache/"$orig_id" ]] && rm -rf ~/.cache/"$orig_id" 2>/dev/null
                        [[ -d ~/.local/share/"$orig_id" ]] && rm -rf ~/.local/share/"$orig_id" 2>/dev/null
                        local base_name=$(echo "$orig_id" | sed 's/-desktop//g; s/-stable//g; s/-git//g; s/-bin//g')
                        if [[ "$base_name" != "$orig_id" ]]; then
                            [[ -d ~/.config/"$base_name" ]] && rm -rf ~/.config/"$base_name" 2>/dev/null
                            [[ -d ~/.cache/"$base_name" ]] && rm -rf ~/.cache/"$base_name" 2>/dev/null
                            [[ -d ~/.local/share/"$base_name" ]] && rm -rf ~/.local/share/"$base_name" 2>/dev/null
                        fi
                        [[ -d ~/."${base_name}" ]] && rm -rf ~/."${base_name}" 2>/dev/null
                    fi
                    ;;
                dnf)
                    sudo dnf remove -y "$orig_id" &>/dev/null || exit_code=1
                    if [[ "$orig_id" =~ ^[a-z0-9-]+$ ]] && [[ ! "$orig_id" =~ ^(python|lib|systemd|xorg|gtk|gnome|kde|qt) ]]; then
                        [[ -d ~/.config/"$orig_id" ]] && rm -rf ~/.config/"$orig_id" 2>/dev/null
                        [[ -d ~/.cache/"$orig_id" ]] && rm -rf ~/.cache/"$orig_id" 2>/dev/null
                        [[ -d ~/.local/share/"$orig_id" ]] && rm -rf ~/.local/share/"$orig_id" 2>/dev/null
                        local base_name=$(echo "$orig_id" | sed 's/-desktop//g; s/-stable//g; s/-git//g; s/-bin//g')
                        if [[ "$base_name" != "$orig_id" ]]; then
                            [[ -d ~/.config/"$base_name" ]] && rm -rf ~/.config/"$base_name" 2>/dev/null
                            [[ -d ~/.cache/"$base_name" ]] && rm -rf ~/.cache/"$base_name" 2>/dev/null
                            [[ -d ~/.local/share/"$base_name" ]] && rm -rf ~/.local/share/"$base_name" 2>/dev/null
                        fi
                        [[ -d ~/."${base_name}" ]] && rm -rf ~/."${base_name}" 2>/dev/null
                    fi
                    ;;
            esac
            exit $exit_code
        ) &
        local PID=$!

        if shred_animation "$PID" "$pkg_display"; then
            echo -e "${GRN}✔ $pkg_display has been shredded.${NC}"
        else
            echo -e "${RED}✘ $pkg_display failed to uninstall.${NC}"
            failed_apps+="$pkg_display ($src_type), "
        fi
    done <<< "$SELECTED"

    if [[ "$OLD_SET" == "-m" ]]; then
        set -m
    else
        set +m
    fi

    [[ -n "$failed_apps" ]] && echo -e "\n${RED}Failed: ${failed_apps%, }${NC}"

    # --- Turbo Clean ---
    echo -e "\n${CYN}➜ Initializing Turbo Clean Protocol...${NC}\n"

    if command -v snap &>/dev/null; then
        echo -ne "${YLW}➜ Purging old Snap revisions...${NC} "
        LANG=en_US.UTF-8 snap list --all 2>/dev/null | awk '/disabled/{print $1, $3}' | while read -r snapname revision; do
            [[ -n "$snapname" && -n "$revision" ]] && sudo snap remove "$snapname" --revision="$revision" &>/dev/null
        done
        echo -e "${GRN}OK${NC}"
    fi

    echo -ne "${YLW}➜ Cleaning AppImage artifacts...${NC} "
    find ~/.local/share/applications -name "*appimage*" -type f 2>/dev/null | while IFS= read -r file; do
        local exec_path
        exec_path=$(grep "^Exec=" "$file" 2>/dev/null | head -1 | cut -d'=' -f2 | cut -d' ' -f1)
        if [[ -n "$exec_path" && ! -f "$exec_path" ]]; then
            rm -f "$file"
        fi
    done
    echo -e "${GRN}OK${NC}"

    if command -v flatpak &>/dev/null; then
        echo -ne "${YLW}➜ Removing unused Flatpak data...${NC} "
        flatpak uninstall --unused -y &>/dev/null
        echo -e "${GRN}OK${NC}"
    fi

    echo -ne "${YLW}➜ Purging unused system configs & cache ($PKG_MGR)...${NC} "
    case "$PKG_MGR" in
        apt)
            sudo apt autoremove -y &>/dev/null
            sudo apt autoclean -y &>/dev/null
            sudo apt clean &>/dev/null
            ;;
        pacman)
            local orphans
            orphans=$(pacman -Qtdq 2>/dev/null)
            [[ -n "$orphans" ]] && sudo pacman -Rns --noconfirm $orphans &>/dev/null
            sudo pacman -Sc --noconfirm &>/dev/null
            ;;
        dnf)
            sudo dnf autoremove -y &>/dev/null
            sudo dnf clean all &>/dev/null
            ;;
    esac
    echo -e "${GRN}OK${NC}"

    sync
    sleep 1
    local END_KB=$(df -k / | awk 'NR==2 {print $4}')
    local SAVED_MB=$(( (START_KB - END_KB) / 1024 ))

    echo -e "\n${GRN}✅ Cleanup Successful!${NC}"
    if (( SAVED_MB > 0 )); then
        echo -e "${CYN}🚀 Total Space Recovered: ${BOLD}${SAVED_MB} MB${NC}\n"
    elif (( SAVED_MB == 0 )); then
        echo -e "${CYN}📊 No significant space change${NC}\n"
    else
        echo -e "${YLW}⚠️  Space calculation shows negative value (disk activity during cleanup)${NC}\n"
    fi
}


# ======================================================
#  📦 Universal Update pack
# ======================================================


uup() {
    # --- UI Colors & Styles ---
    local RED='\033[1;31m' GRN='\033[1;32m' YLW='\033[1;33m' BLU='\033[1;34m'
    local PUR='\033[1;35m' CYN='\033[1;36m' BOLD='\033[1m' NC='\033[0m'

    # --- OS & Package Manager Detection ---
    local OS_TYPE=$(uname -s)
    local PKG_MGR=""
    if [ "$OS_TYPE" = "Linux" ]; then
        if command -v apt &>/dev/null; then PKG_MGR="apt"
        elif command -v pacman &>/dev/null; then PKG_MGR="pacman"
        elif command -v dnf &>/dev/null; then PKG_MGR="dnf"
        fi
    elif [ "$OS_TYPE" = "Darwin" ]; then PKG_MGR="brew"; fi


    # --- Dependency Check (fzf) ---
    if ! command -v fzf &>/dev/null; then
        echo -e "${YLW}🔍 fzf not found. Installing...${NC}"
        if [ "$OS_TYPE" = "Darwin" ] || command -v brew &>/dev/null; then brew install fzf
        elif [ "$PKG_MGR" = "apt" ]; then sudo apt update && sudo apt install fzf -y
        elif [ "$PKG_MGR" = "pacman" ]; then sudo pacman -S fzf --noconfirm
        elif [ "$PKG_MGR" = "dnf" ]; then sudo dnf install fzf -y
        fi
    fi


    clear
    echo ""
    echo -e "  ${BOLD}Manager:${NC} $PKG_MGR | ${BOLD}User:${NC} $(whoami) | ${BOLD}OS:${NC} $OS_TYPE"
    echo ""
    # --- Step 0: Smart Selection via FZF ---
    local tasks=(
        "0. ALL_MAINTENANCE_TASKS"
        "1. Core_System_Update"
        "2. Snap_Package_Refresh"
        "3. Flatpak_Cleanup_Update"
        "4. Bun_Runtime_Upgrade"
        "5. Node.js_LTS_Sync"
        "6. Global_NPM_Update"
        "7. Full_System_Deep_Clean"
    )

    # Fixed FZF Color Typo (#9ece6a)
    local SELECTED_TASKS=$(printf "%s\n" "${tasks[@]}" | fzf \
        --ansi --multi --height=18 --layout=reverse --border=rounded \
        --prompt="⚡ Action: " --header="[TAB] Select | [ENTER] Execute" \
        --color='bg+:#292e42,hl:#bb9af7,prompt:#7dcfff,pointer:#f7768e,marker:#9ece6a' \
        --preview 'if [[ {1} == "0." ]]; then echo "Execute all updates and cleanup."; else echo "Action: {1}" | sed "s/_/ /g"; fi' \
        --preview-window='up:1:wrap')

    [ -z "$SELECTED_TASKS" ] && { echo -e "${RED}❌ No tasks selected. Aborting...${NC}"; return; }

    # --- Sudo Keep-alive ---
    echo -e "${YLW}🔑 Requesting sudo permission...${NC}"
    sudo -v || return
    (while true; do sudo -n true; sleep 60; done) 2>/dev/null &
    local SUDO_PID=$!
    trap "kill $SUDO_PID 2>/dev/null" EXIT INT TERM

    # --- Execute All Logic ---
    if [[ "$SELECTED_TASKS" == *"0. ALL_MAINTENANCE_TASKS"* ]]; then
        SELECTED_TASKS=$(printf "%s\n" "${tasks[@]}")
    fi

    # 1. OS Core
    if [[ "$SELECTED_TASKS" == *"1. Core_System_Update"* ]]; then
        echo -e "\n${BOLD}${YLW}🔍 [1/7] Updating OS Core ($PKG_MGR)...${NC}"
        echo ""
        case "$PKG_MGR" in
            apt) sudo apt update && sudo apt upgrade -y ;;
            pacman) sudo pacman -Syu --noconfirm ;;
            dnf) sudo dnf upgrade --refresh -y ;;
            brew) brew update && brew upgrade ;;
        esac
    fi

    # 2. Snap
    if [[ "$SELECTED_TASKS" == *"2. Snap_Package_Refresh"* ]]; then
        echo -e "\n${BOLD}${GRN}📦 [2/7] Checking Snap Environment...${NC}"
        echo ""
        if ! command -v snap &>/dev/null; then
            echo -e "  ${YLW}⚠ Snap is not installed on this system. Skipping...${NC}"
        else
            local sc=$(snap refresh --list 2>/dev/null)
            [[ -n "$sc" && "$sc" != *"up to date"* ]] && sudo snap refresh || echo -e "  ${BLU}ℹ Snaps are up-to-date.${NC}"
        fi
    fi

    # 3. Flatpak
    if [[ "$SELECTED_TASKS" == *"3. Flatpak_Cleanup_Update"* ]]; then
        echo -e "\n${BOLD}${CYN}💎 [3/7] Checking Flatpak Environment...${NC}"
        echo ""
        if ! command -v flatpak &>/dev/null; then
            echo -e "  ${YLW}⚠ Flatpak is not installed on this system. Skipping...${NC}"
        else
            local f_updates=$(flatpak remote-ls --updates 2>/dev/null)
            if [ -z "$f_updates" ]; then
                echo -e "  ${BLU}No Flatpak updates available. Skipping...${NC}"
            else
                flatpak update -y
                echo -e "  ${GRN}✅ Flatpak updated!${NC}"
            fi
            flatpak uninstall --unused -y &>/dev/null
        fi
    fi

    # 4. Bun
    if [[ "$SELECTED_TASKS" == *"4. Bun_Runtime_Upgrade"* ]]; then
        echo -e "\n${BOLD}${CYN}🥬 [4/7] Upgrading Bun Runtime...${NC}"
        echo ""
        if command -v bun &>/dev/null; then
            bun upgrade
        else
            echo -e "  ${YLW}⚠ Bun is not installed. Skipping...${NC}"
        fi
    fi

    # 5. Node.js
    if [[ "$SELECTED_TASKS" == *"5. Node.js_LTS_Sync"* ]]; then
        echo -e "\n${BOLD}${PUR}🟢 [5/7] Syncing Node.js (LTS Version)...${NC}"
        echo ""
        local NVM_PATH="${NVM_DIR:-$HOME/.nvm}/nvm.sh"
        if [ -f "$NVM_PATH" ]; then
            source "$NVM_PATH"
            nvm install --lts --reinstall-packages-from=node
            nvm use --lts
            nvm alias default 'lts/*'
        else
            echo -e "  ${YLW}⚠ NVM/Node not found. Skipping...${NC}"
        fi
    fi

    # 6. Global NPM
    if [[ "$SELECTED_TASKS" == *"6. Global_NPM_Update"* ]]; then
        echo -e "\n${BOLD}${YLW}✨ [6/7] Finalizing NPM Update...${NC}"
        echo ""
        if command -v npm &>/dev/null; then
            npm install -g npm@latest
        else
            echo -e "  ${YLW}⚠ NPM is not installed. Skipping...${NC}"
        fi
    fi

    # --- 8. Full Deep Clean (Now including Snap & Flatpak) ---
    if [[ "$SELECTED_TASKS" == *"7. Full_System_Deep_Clean"* ]]; then
        echo -e "\n${BOLD}${RED}📦 [7/7] Full System Deep Cleaning...${NC}"
        echo ""
        # OS Native Clean
        case "$PKG_MGR" in
            apt) sudo apt autoremove -y && sudo apt autoclean ;;
            pacman) sudo pacman -Rns $(pacman -Qtdq) --noconfirm 2>/dev/null || echo -e "  ${BLU}ℹ No orphans.${NC}" ;;
            dnf) sudo dnf autoremove -y ;;
            brew) brew cleanup ;;
        esac

        # Snap Clean
        if command -v snap &>/dev/null; then
            echo -e "  ${CYN}📦 Cleaning old Snap revisions...${NC}"
            LANG=C snap list --all | awk '/disabled/{print $1, $3}' | while read sn rv; do sudo snap remove "$sn" --revision="$rv"; done
        fi

        # Flatpak Deep Clean (NEW)
        if command -v flatpak &>/dev/null; then
            echo ""
            echo -e "${CYN}💎 Cleaning Flatpak unused runtimes & cache...${NC}"
            flatpak uninstall --unused -y &>/dev/null
            flatpak repair --user &>/dev/null
            flatpak repair &>/dev/null
            # Cleaning flatpak cache
            rm -rf ~/.var/app/*/cache/* &>/dev/null
            echo -e "  ${GRN}✅ Flatpak cleaned.${NC}"
        fi
    fi

    echo -e "\n${PUR}─────────────────────────────────────────────────────────────${NC}"
    echo -e "  ${BOLD}${GRN}✅ MISSION ACCOMPLISHED! YOUR PC IS NOW AT MAX POWER.${NC}"
    echo -e "${PUR}─────────────────────────────────────────────────────────────${NC}"

    # Notification (Fixed Multi-OS)
    if [ "$OS_TYPE" = "Darwin" ]; then
        osascript -e 'display notification "System optimized successfully" with title "uup Tool"' 2>/dev/null
    elif command -v notify-send &>/dev/null; then
        notify-send "uup Tool" "All selected updates completed successfully."
    fi
}



# ======================================================
#  🆘 HELP MENU — Modern UI/UX Edition
# ======================================================
keep() {
    # Modern Color Palette
    RESET='\033[0m'
    BOLD='\033[1m'
    DIM='\033[2m'

    # Primary Colors
    CYAN='\033[38;5;51m'      # Electric Cyan
    PINK='\033[38;5;213m'     # Hot Pink
    PURPLE='\033[38;5;141m'   # Soft Purple
    GREEN='\033[38;5;82m'     # Neon Green
    YELLOW='\033[38;5;220m'   # Gold Yellow
    ORANGE='\033[38;5;208m'   # Orange
    BLUE='\033[38;5;75m'      # Sky Blue
    RED='\033[38;5;203m'      # Soft Red
    WHITE='\033[38;5;255m'    # Pure White
    GRAY='\033[38;5;245m'     # Gray

    # Background Colors
    BG_DARK='\033[48;5;234m'  # Dark background
    BG_CARD='\033[48;5;236m'  # Card background

    # Icons
    ICON_ROCKET='🚀'
    ICON_FOLDER='📂'
    ICON_FILE='📄'
    ICON_GEAR='⚙️'
    ICON_PACKAGE='📦'
    ICON_BUN='🥐'
    ICON_GIT='🌿'
    ICON_LIGHTNING='⚡'
    ICON_TERMINAL='💻'
    ICON_WARNING='⚠️'
    ICON_STAR='✨'
    ICON_SEARCH='🔍'

    # Clear screen for clean look
    clear

    # Header with gradient effect

    echo -e "${CYAN} ╔══════════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN} ║${RESET}  ${BOLD}${PINK}${ICON_ROCKET}  MASTER COMMAND CENTER ${RESET}${CYAN}│${RESET} ${GRAY}Developer Rihad's Ultimate Bash Environment${RESET}      ${CYAN} ${RESET}"
    echo -e "${CYAN} ╚══════════════════════════════════════════════════════════════════════════╝${RESET}"
    echo -e "${GRAY}  v2.0 • Modern Terminal UX • $(date +'%B %d, %Y')${RESET}\n"

    # Function to print category headers
    print_category() {
        local icon=$1
        local title=$2
        local color=$3
        echo -e "\n  ${color}┌─────────────────────────────────────────────────────────────────────┐${RESET}"
        echo -e "  ${color}│${RESET} ${BOLD}${icon}  ${title}${RESET}${color}                                    ${RESET}"
        echo -e "  ${color}└─────────────────────────────────────────────────────────────────────┘${RESET}"
    }

    # Function to print command row
    print_cmd() {
        local cmd=$1
        local desc=$2
        local example=$3
        local cmd_color=$4

        if [ -z "$example" ]; then
            printf "     ${BOLD}${cmd_color}%-12s${RESET} ${GRAY}│${RESET} %s\n" "$cmd" "$desc"
        else
            printf "     ${BOLD}${cmd_color}%-12s${RESET} ${GRAY}│${RESET} %-35s ${DIM}%s${RESET}\n" "$cmd" "$desc" "$example"
        fi
    }

    # Function to print alias row
    print_alias() {
        local alias=$1
        local equals=$2
        local full=$3
        local color=$4
        printf "     ${BOLD}${color}%-6s${RESET} ${GRAY}%s${RESET} ${DIM}%s${RESET}\n" "$alias" "$equals" "$full"
    }

    # ==================== NAVIGATION ====================
    print_category "$ICON_FOLDER" "NAVIGATION & MOVEMENT" "$CYAN"
    print_cmd ".." "Parent directory" "" "$YELLOW"
    print_cmd "..." "Two levels up" "" "$YELLOW"
    print_cmd "...." "Three levels up" "" "$YELLOW"
    print_cmd "dev" "Go to ~/Development" "" "$GREEN"
    print_cmd "fr / ba / fu" "Frontend / Backend / Fullstack" "" "$GREEN"
    print_cmd "fig / ar / de" "Figma / Archive / Dev folders" "" "$GREEN"
    print_cmd "des / doc / dow" "Desktop / Documents / Downloads" "" "$GREEN"

    # ==================== FILE OPERATIONS ====================
    print_category "$ICON_FILE" "FILE & FOLDER MANAGEMENT" "$PINK"
    print_cmd "mkd <name>" "Create & enter directory" "mkd new-project" "$YELLOW"
    print_cmd "rmd <name>" "Force remove directory" "rmd old-folder" "$RED"
    print_cmd "rmf <file>" "Remove file (safe)" "rmf file.txt" "$RED"
    print_cmd "bak <file>" "Create backup copy" "bak .env" "$BLUE"
    print_cmd "trash <file>" "Move to system trash" "trash junk.txt" "$ORANGE"
    print_cmd "to" "Open current folder in VS Code" "" "$CYAN"

    # ==================== NPM ====================
    print_category "$ICON_PACKAGE" "NPM COMMANDS" "$GREEN"
    print_alias "ni" "→" "npm install" "$GREEN"
    print_alias "nid" "→" "npm install -D" "$GREEN"
    print_alias "nr" "→" "npm run" "$GREEN"
    print_alias "nrd" "→" "npm run dev" "$YELLOW"
    print_alias "nrb" "→" "npm run build" "$YELLOW"
    print_alias "nrs" "→" "npm run start" "$YELLOW"

    # ==================== BUN ====================
    print_category "$ICON_BUN" "BUN COMMANDS (Ultra Fast)" "$YELLOW"
    print_alias "bi" "→" "bun install" "$YELLOW"
    print_alias "br" "→" "bun run" "$YELLOW"
    print_alias "brd" "→" "bun run dev" "$GREEN"
    print_alias "brb" "→" "bun run build" "$GREEN"
    print_alias "brs" "→" "bun run start" "$GREEN"
    print_alias "html" "→" "bun run index.html" "$CYAN"

    # ==================== GIT ====================
    print_category "$ICON_GIT" "GIT VERSION CONTROL" "$PURPLE"
    print_cmd "gi" "Initialize new repository" "" "$GREEN"
    print_cmd "gs" "Check status (short format)" "" "$BLUE"
    print_cmd "ga" "Stage all files" "" "$YELLOW"
    print_cmd "gcm <msg>" "Commit with message" "gcm 'feat: add login'" "$GREEN"
    print_cmd "gps / gpl" "Push / Pull from remote" "" "$PINK"
    print_cmd "gl" "View beautiful git log" "" "$CYAN"
    print_cmd "gco <branch>" "Checkout branch" "gco main" "$YELLOW"
    print_cmd "gcb <name>" "Create & checkout new branch" "gcb feature-x" "$GREEN"
    print_cmd "gd" "View diff" "" "$ORANGE"
    print_cmd "gst / gsta / gpop" "Stash / Apply / Pop" "" "$BLUE"
    print_cmd "gwip" "Quick WIP commit + auto push" "" "$PINK"

    # ==================== PROJECT SETUP ====================
    print_category "$ICON_LIGHTNING" "PROJECT INITIALIZATION" "$ORANGE"
    print_cmd "init" "Initialize project (Bun/NPM choice)" "" "$GREEN"
    print_cmd "next" "Setup Next.js project" "" "$CYAN"
    print_cmd "ui" "Setup Shadcn UI with components" "ui + select button,card" "$BLUE"
    print_cmd "vite" "Setup Vite project with Tailwind" "" "$PURPLE"
    print_cmd "css" "Auto-install Tailwind CSS" "" "$BLUE"
    print_cmd "run" "Bun Run JS & TS File (Interactive)" "" "$YELLOW"

    # ==================== C / C++ ====================
    print_category "$ICON_GEAR" "C/C++ DEVELOPMENT" "$CYAN"
    print_cmd "makecpp" "C/C++ boilerplate (cd, git, vscode)" "makecpp proj_name" "$BLUE"
    print_cmd "make run" "Compile and run the C/C++ project" "" "$GREEN"
    print_cmd "make clean" "Remove compiled binary file" "" "$RED"

    # ==================== SYSTEM ====================
    print_category "$ICON_GEAR" "SYSTEM & MAINTENANCE" "$BLUE"
    print_cmd "update" "Update system packages" "" "$GREEN"
    print_cmd "clean" "Clean apt cache & orphans" "" "$YELLOW"
    print_cmd "uup" "MEGA UPDATE: Apt+Snap+Flatpak+Bun+Node" "" "$PINK"
    print_cmd "uu" "UNINSTALLER: Remove apps interactively" "" "$RED"
    print_cmd "uc" "Universal Clean" "" "$YELLOW"
    print_cmd "setuppc" "Setup new PC with all tools" "" "$CYAN"
    print_cmd "rel" "Reload .bashrc configuration" "" "$GREEN"
    print_cmd "myip / iploc" "Show IP / Location info" "" "$BLUE"
    print_cmd "ports" "Show open ports" "" "$YELLOW"
    print_cmd "kp <port>" "Kill process on port" "kp 3000" "$RED"
    print_cmd "serve" "Start Python HTTP server" "" "$GREEN"
    print_cmd "ut" "Setup cli tool for pc Optimized" "" "$CYAN"
    print_cmd "rt" " Install Node(nvm) , Bun , Deno" "" "$YELLOW"
    print_cmd "rn" "Renamed All file @ & % * # @" "" "$PINK"


    # ==================== UTILITIES ====================
    print_category "$ICON_TERMINAL" "UTILITY TOOLS" "$CYAN"
    print_cmd "ex <file>" "Extract any archive" "ex file.zip" "$GREEN"
    print_cmd "ff <name>" "Find file (excludes node_modules)" "ff config" "$YELLOW"
    print_cmd "gen <len>" "Generate random secret key" "gen 32" "$PURPLE"
    print_cmd "h <word>" "Search command history" "h git" "$BLUE"
    print_cmd "c / cls" "Clear terminal screen" "" "$GRAY"
    print_cmd "v" "Interactive video player for directory" "" "$PINK"
    print_cmd "pg" "Generate package.json for current project" "" "$PURPLE"

    # ==================== DOCKER & CONTAINERS ====================
    print_category "$ICON_BUN" "DOCKER & CONTAINERS" "$YELLOW"
    print_cmd "dps" "List running containers" "" "$GREEN"
    print_cmd "dpsa" "List all containers" "" "$YELLOW"
    print_cmd "di" "Show Docker images" "" "$CYAN"
    print_cmd "dvl" "List Docker volumes" "" "$CYAN"
    print_cmd "dnl" "List Docker networks" "" "$CYAN"
    print_cmd "dsize" "Inspect Docker disk usage" "" "$BLUE"
    print_cmd "dtop" "Show container resource usage" "" "$BLUE"
    print_cmd "dstop <name>" "Stop container" "dstop myapp" "$RED"
    print_cmd "drm <name>" "Remove container" "drm myapp" "$RED"
    print_cmd "drmi <name>" "Remove image" "drmi myimage" "$RED"
    print_cmd "drestart <name>" "Restart container" "drestart myapp" "$ORANGE"
    print_cmd "dkill <name>" "Force remove container" "dkill myapp" "$ORANGE"
    print_cmd "dstopall" "Stop all running containers" "" "$ORANGE"
    print_cmd "drmall" "Remove all containers" "" "$ORANGE"
    print_cmd "dbuild <tag>" "Build Docker image" "dbuild myapp ." "$GREEN"
    print_cmd "dbuild-nocache <tag>" "Build without cache" "dbuild-nocache myapp ." "$GREEN"
    print_cmd "dhist <image>" "Show image history" "dhist myimage" "$CYAN"
    print_cmd "dports <name>" "Inspect container ports" "dports myapp" "$CYAN"
    print_cmd "dsh <name>" "Shell into container" "dsh myapp bash" "$BLUE"
    print_cmd "dlogs <name>" "Follow logs" "dlogs myapp" "$CYAN"
    print_cmd "dcup / dcdn" "Compose up/down" "dcup / dcdn" "$PURPLE"
    print_cmd "dclogs" "Follow compose logs" "dclogs" "$PURPLE"
    print_cmd "dcupb" "Compose up with build" "dcupb" "$PURPLE"
    print_cmd "dtest-ubuntu / dtest-node / dtest-alpine" "Launch test containers" "dtest-node" "$GREEN"
    print_cmd "dfind <term>" "Search containers/images" "dfind nginx" "$YELLOW"
    print_cmd "droot <name>" "Enter container as root" "droot myapp" "$YELLOW"
    print_cmd "dip <name>" "Show container IP" "dip myapp" "$BLUE"
    print_cmd "dwatch <name>" "Watch container changes" "dwatch myapp" "$CYAN"
    print_cmd "dnetstat <name>" "Inspect container network" "dnetstat myapp" "$CYAN"
    print_cmd "dtop-proc <name>" "Show process tree" "dtop-proc myapp" "$PURPLE"
    print_cmd "dbackup <name> <archive>" "Backup volume to tar" "dbackup data data.tar" "$GREEN"
    print_cmd "dkill-force" "Force remove all containers" "dkill-force" "$RED"
    print_cmd "dclean" "Clean unused Docker resources" "dclean" "$RED"
    print_cmd "dstart" "Start Docker service" "" "$GREEN"
    print_cmd "doff" "Stop Docker service" "" "$RED"
    print_cmd "dstatus" "Check Docker service status" "" "$BLUE"
    print_cmd "denable" "Enable Docker auto-start on boot" "" "$GREEN"
    print_cmd "ddisable" "Disable Docker auto-start on boot" "" "$ORANGE"

    # ==================== ADVANCED INTERACTIVE TOOLS ====================
    print_category "$ICON_LIGHTNING" "ADVANCED INTERACTIVE TOOLS" "$PURPLE"
    print_cmd "cf" "Fuzzy find & navigate directories" "" "$CYAN"
    print_cmd "   ↳ ENTER" "cd to selected folder" "" "$GREEN"
    print_cmd "   ↳ CTRL+O" "Open in VS Code/Cursor/Nvim" "" "$BLUE"
    print_cmd "   ↳ CTRL+Y" "Copy path to clipboard" "" "$YELLOW"
    print_cmd "   ↳ CTRL+H" "Navigate to parent directory" "" "$PURPLE"
    print_cmd "mkd <name>" "Create & enter new directory" "mkd my-project" "$GREEN"
    print_cmd "rmd <name>" "Force remove directory" "rmd old-folder" "$RED"
    print_cmd "rmf <file>" "Safe remove single file" "rmf file.txt" "$ORANGE"
    print_cmd "bak <file>" "Create backup of file" "bak config.js" "$BLUE"
    print_cmd "trash <file>" "Move file to system trash" "trash junk.txt" "$YELLOW"

    # ==================== FILE MANAGEMENT ====================
    print_category "$ICON_FILE" "FOLDER UTILITIES" "$BLUE"
    print_cmd "mkd / rmd / rmf" "Create/Remove directories/files" "" "$YELLOW"
    print_cmd "bak / trash" "Backup or trash files safely" "" "$ORANGE"
    print_cmd "cd <folder>" "Smart cd with auto-list files" "" "$CYAN"

    # ==================== FOOTER ====================
    echo -e "\n  ${PURPLE}┌─────────────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "  ${PURPLE}│${RESET}  ${ICON_STAR} ${BOLD}PRO TIPS:${RESET}                                                        ${PURPLE} ${RESET}"
    echo -e "  ${PURPLE}│${RESET}    • ${YELLOW}cd <folder>${RESET} automatically lists files with colors             ${PURPLE} ${RESET}"
    echo -e "  ${PURPLE}│${RESET}    • Type ${CYAN}folder name only${RESET} to auto-cd (autocd enabled)            ${PURPLE} ${RESET}"
    echo -e "  ${PURPLE}│${RESET}    • ${GRAY}Prompt shows:${RESET} Git status │ Node/Bun versions │ System stats    ${PURPLE} ${RESET}"
    echo -e "  ${PURPLE}└─────────────────────────────────────────────────────────────────────┘${RESET}"



    echo ""
    echo -e "        \e[1;36m========================================================================\e[0m"
    echo -e "        \e[1;33m          🚀 MY LINUX SETUP LIST         \e[0m"
    echo -e "        \e[1;36m========================================================================\e[0m"

    echo -e "           \e[1;32m[📦 FLATPAK APPS]\e[0m"
    echo -e "           • Brave, Flatseal, ytDownloader, Packet"
    echo -e "           • Inkscape, Bazaar, Vlc, Zed"
    echo ""

    echo -e "           \e[1;34m[⚙️ CORE DEB & TOOLS]\e[0m"
    echo -e "           • VS Code, Chrome"
    echo -e "           • Zram, Fzf, Preload, Earlyoom, ls-sensors"
    echo ""

    echo -e "           \e[1;35m[🛠️ DEV TOOLS]\e[0m"
    echo -e "           • Git, Nodejs, Bun, Curl, Wget"

    echo -e "        \e[1;36m========================================================================\e[0m"
    echo ""



    # Dynamic stats
    echo -e "\n  ${DIM}$(date +'%H:%M:%S') • Bash v${BASH_VERSION:0:3} • $(whoami)@$(hostname) • $PWD${RESET}\n"
}

# ======================================================
#  📦 Run ts / js file on terminal
# ======================================================

run() {
    # Color Codes
    local CYAN='\033[0;36m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[1;34m'
    local GREEN='\033[1;32m'
    local RED='\033[0;31m'
    local BOLD='\033[1m'
    local NC='\033[0m'

    # zsh: nullglob enable (local scope)
    setopt localoptions nullglob

    # Safe file collection - zsh native glob with (N) qualifier
    local files=(*.js(N) *.ts(N))

    if (( ${#files} == 0 )); then
        echo -e "${RED}󱓇 No .js or .ts files found!${NC}"
        return 1
    fi

    # Modern Header
    echo -e "\n${CYAN}╭──────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│${NC}  ${BOLD}⚡ BUN INTERACTIVE RUNNER${NC}               ${CYAN}│${NC}"
    echo -e "${CYAN}╰──────────────────────────────────────────╯${NC}"

    # List Display with Icons
    local i ext icon
    # zsh: array index 1-based
    for (( i = 1; i <= ${#files}; i++ )); do
        ext="${files[$i]##*.}"
        if [[ "$ext" == "ts" ]]; then
            icon="${BLUE}📘${NC}"
        else
            icon="${YELLOW}📒${NC}"
        fi
        printf "${CYAN}  [%2d]${NC}  %b  %-30s\n" "$i" "$icon" "${files[$i]}"
    done

    echo -e "${CYAN}────────────────────────────────────────────${NC}"

    # Smart Input Prompt
    echo -e "${YELLOW}👉 Enter file number (or Ctrl+C):${NC}"
    echo -ne "${YELLOW}❯ ${NC}"
    local choice
    read -r choice

    # Strict validation
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#files} )); then
        # zsh: 1-based index, so direct access
        local selected_file="${files[$choice]}"

        echo -e "\n${GREEN}✔ Selected:${NC} ${BOLD}$selected_file${NC}"
        echo -e "${CYAN}────────────────────────────────────────────${NC}"

        # Mode Selection Menu
        echo -e "\n${YELLOW}👉 Choose run mode:${NC}"
        echo -e "${CYAN}  [1]${NC}  🚀  ${BOLD}bun run${NC}     (default)"
        echo -e "${CYAN}  [2]${NC}  🔥  ${BOLD}bun --hot${NC}   (hot reload)"
        echo -e "${CYAN}  [3]${NC}  👁  ${BOLD}bun --watch${NC} (watch mode)"
        echo -e "${CYAN}────────────────────────────────────────────${NC}"
        echo -ne "${YELLOW}❯ ${NC}"
        local mode
        read -r mode

        local cmd mode_label mode_color
        case "$mode" in
            2)
                cmd="bun --hot"
                mode_label="HOT RELOAD"
                mode_color="${RED}"
                ;;
            3)
                cmd="bun --watch"
                mode_label="WATCH MODE"
                mode_color="${YELLOW}"
                ;;
            1|"")
                cmd="bun run"
                mode_label="RUN"
                mode_color="${GREEN}"
                ;;
            *)
                echo -e "\n${RED}✘ Error: Invalid mode! Defaulting to 'bun run'.${NC}"
                cmd="bun run"
                mode_label="RUN"
                mode_color="${GREEN}"
                ;;
        esac

        echo -e "\n${mode_color}⚙ $mode_label:${NC} ${BOLD}$selected_file${NC}\n"

        # Execute
        $cmd "$selected_file"
    else
        echo -e "\n${RED}✘ Error: Invalid selection!${NC}"
        return 1
    fi
}


# ======================================================
#  📦 VIDEO FILLTER AND OPEN
# ======================================================



v() {
    local DIR="${1:-$PWD}"
    local PLAYER=""

    # 🎥 Player check (Flatpak VLC Priority)
    if flatpak info org.videolan.VLC >/dev/null 2>&1; then
        PLAYER='flatpak run org.videolan.VLC'
    elif command -v mpv >/dev/null 2>&1; then
        PLAYER='mpv --fs --no-terminal'
    else
        PLAYER='vlc'
    fi

    # 🔍 Find Videos
    local RAW_LIST
    RAW_LIST=$(find "$DIR" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" -o -iname "*.flv" \) | sort)

    [ -z "$RAW_LIST" ] && echo "❌ No videos found" && return 1

    # 🎨 UI Header
    local HEADER_STR=$(printf "\e[1;34m%-5s \e[1;33m%-20s \e[1;35m%-s\e[0m" "IDX" "FOLDER" "VIDEO NAME")

    local SELECTED_LINE
    SELECTED_LINE=$(echo "$RAW_LIST" | awk -F/ '{
        idx = NR;
        folder = $(NF-1);
        filename = $NF;
        folder_with_icon = "📁 " folder;
        if (length(filename) > 55) filename = substr(filename, 1, 52) "...";
        if (length(folder_with_icon) > 17) folder_with_icon = substr(folder_with_icon, 1, 14) "...";
        printf "\033[34m%-5s \033[33m%-20s \033[0m%s\n", idx, folder_with_icon, filename
    }' | fzf \
        --ansi \
        --reverse \
        --height=60% \
        --border=rounded \
        --header="$HEADER_STR" \
        --header-first \
        --prompt="🔍 Search: " \
        --pointer="▶" \
        --color="bg+:-1,fg+:white,hl:yellow,hl+:cyan,header:blue,prompt:cyan,pointer:green")

    if [ -n "$SELECTED_LINE" ]; then
        local INDEX=$(echo "$SELECTED_LINE" | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $1}')

        if ! [[ "$INDEX" =~ ^[0-9]+$ ]]; then
            echo "❌ Invalid selection"
            return 1
        fi

        local FULL_PATH=$(echo "$RAW_LIST" | sed -n "${INDEX}p")

        if [ -z "$FULL_PATH" ] || [ ! -f "$FULL_PATH" ]; then
            echo "❌ Video file not found"
            return 1
        fi

        echo -e "\e[1;92m▶ Playing:\e[0m $(basename "$FULL_PATH")"

        # ✅ Zsh-এর পারফেক্ট ডিটাচড মেথড (&!)
        ${=PLAYER} "$FULL_PATH" >/dev/null 2>&1 &!
    else
        echo "👋 Exit"
    fi
}

# ======================================================
#  📦universal clean
# ======================================================


uc() {
    # ==============================
    # 🎨 COLORS & SAFETY
    # ==============================
    local RED="\033[0;31m" GREEN="\033[0;32m" YELLOW="\033[1;33m"
    local BLUE="\033[0;34m" CYAN="\033[0;36m" MAGENTA="\033[0;35m" NC="\033[0m"

    set -o pipefail
    # ZSH FIX: errexit DISABLED — it fires the EXIT trap before LOG_FILE is
    # initialized (leaving it empty), which causes: _log:1: no such file or directory:
    # set -o errexit
    # ZSH FIX: nounset causes issues with unset variables in Zsh
    # set -o nounset  # DISABLED for Zsh compatibility

    # ==============================
    # 🔐 TRAP & LOG SETUP
    # ==============================
    local LOG_FILE="/tmp/uc-optimizer-$(id -u).log"

    # Try to use HOME first, fallback to /tmp
    if [[ -d "${HOME:-}" ]]; then
        local cache_dir="${HOME}/.cache/uc-optimizer"
        if mkdir -p "$cache_dir" 2>/dev/null; then
            LOG_FILE="${cache_dir}/optimizer.log"
        fi
    fi

    # Security: Remove symlink if exists
    if [[ -L "$LOG_FILE" ]]; then
        rm -f "$LOG_FILE" 2>/dev/null || LOG_FILE="/dev/null"
    fi

    # Create log file
    if ! touch "$LOG_FILE" 2>/dev/null; then
        LOG_FILE="/dev/null"
    fi

    _log() {
        # Guard: never write to empty path (happens if trap fires before LOG_FILE is set)
        [[ -z "${LOG_FILE:-}" ]] && return 0
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE" 2>/dev/null || true
    }

    _trap_exit() {
        local exit_code=$?
        trap - INT TERM EXIT
        echo -e "\n${RED}⚠️  Interrupted (Exit code: $exit_code)${NC}" >&2
        _log "Session interrupted with code $exit_code"
        # ZSH FIX: use 'return' not 'exit' inside a function — 'exit' kills the
        # entire shell and triggers "you have running jobs" from process substitutions.
        return 130
    }
    trap _trap_exit INT TERM EXIT

    _log "Session started [UID: $(id -u), PID: $$]"

    # ==============================
    # 🐧 DISTRO DETECTION
    # ==============================
    _detect_distro() {
        local d_id="unknown" d_name="Unknown Linux"

        if [[ -r /etc/os-release ]]; then
            # Source safely with restricted scope
            while IFS='=' read -r key value; do
                case "$key" in
                    ID) d_id="${value//\"/}" ;;
                    NAME) d_name="${value//\"/}" ;;
                esac
            done < /etc/os-release
            d_id=$(echo "$d_id" | tr '[:upper:]' '[:lower:]')
        elif [[ -r /etc/redhat-release ]]; then
            d_id="rhel"
            d_name="Red Hat Enterprise Linux"
        elif [[ -r /etc/arch-release ]]; then
            d_id="arch"
            d_name="Arch Linux"
        elif [[ -r /etc/alpine-release ]]; then
            d_id="alpine"
            d_name="Alpine Linux"
        fi

        # Validate ID format
        if [[ ! "$d_id" =~ ^[a-z0-9._-]+$ ]]; then
            d_id="unknown"
        fi

        printf '%s|%s' "$d_id" "$d_name"
    }

    local distro_info
    distro_info=$(_detect_distro)
    local DISTRO_ID="${distro_info%%|*}"
    local DISTRO_NAME="${distro_info##*|}"

    # Fallback if parsing failed
    [[ -z "$DISTRO_ID" ]] && DISTRO_ID="unknown"
    [[ -z "$DISTRO_NAME" ]] && DISTRO_NAME="Unknown"

    echo -e "${CYAN}╔════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}   🚀 System Optimizer v3.0         ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════╝${NC}"
    echo -e "${CYAN}OS:${NC} $DISTRO_NAME"
    echo -e "${CYAN}ID:${NC} $DISTRO_ID"
    echo ""

    _log "Distro detected: $DISTRO_NAME ($DISTRO_ID)"

    # ==============================
    # 🔒 PACKAGE MANAGER
    # ==============================
    _sudo_check() {
        if [[ $EUID -eq 0 ]]; then
            return 0  # Already root
        fi
        if ! sudo -n true 2>/dev/null; then
            echo -e "${YELLOW}🔐 Sudo authentication required...${NC}"
            if ! sudo -v; then
                echo -e "${RED}❌ Sudo authentication failed${NC}" >&2
                return 1
            fi
        fi
        return 0
    }

    _pkg_install() {
        local pkgs=("$@")
        local pkg_manager=""

        _sudo_check || return 1

        # Detect package manager
        case "$DISTRO_ID" in
            ubuntu|debian|linuxmint|pop|elementary|zorin)
                pkg_manager="apt"
                ;;
            fedora|rhel|centos|rocky|almalinux|nobara)
                if command -v dnf >/dev/null 2>&1; then
                    pkg_manager="dnf"
                else
                    pkg_manager="yum"
                fi
                ;;
            arch|manjaro|endeavouros|garuda|cachyos)
                pkg_manager="pacman"
                ;;
            opensuse*|suse*|tumbleweed|leap)
                pkg_manager="zypper"
                ;;
            alpine)
                pkg_manager="apk"
                ;;
            void)
                pkg_manager="xbps"
                ;;
            gentoo)
                pkg_manager="emerge"
                ;;
            nixos)
                pkg_manager="nix"
                ;;
            *)
                echo -e "${RED}❌ Unsupported distro: $DISTRO_ID${NC}" >&2
                return 1
                ;;
        esac

        echo -e "${BLUE}📦 Installing: ${pkgs[*]}${NC}"

        local exit_code=0
        case "$pkg_manager" in
            apt)
                sudo apt-get update -qq && \
                sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${pkgs[@]}"
                exit_code=$?
                ;;
            dnf)
                sudo dnf install -y --setopt=install_weak_deps=False "${pkgs[@]}"
                exit_code=$?
                ;;
            yum)
                sudo yum install -y "${pkgs[@]}"
                exit_code=$?
                ;;
            pacman)
                sudo pacman -Sy --noconfirm --needed "${pkgs[@]}"
                exit_code=$?
                ;;
            zypper)
                sudo zypper --non-interactive install --no-recommends "${pkgs[@]}"
                exit_code=$?
                ;;
            apk)
                sudo apk add --no-cache "${pkgs[@]}"
                exit_code=$?
                ;;
            xbps)
                sudo xbps-install -y "${pkgs[@]}"
                exit_code=$?
                ;;
            emerge)
                sudo emerge -av "${pkgs[@]}"
                exit_code=$?
                ;;
            nix)
                sudo nix-env -iA "${pkgs[@]/#/nixpkgs.}"
                exit_code=$?
                ;;
        esac

        return $exit_code
    }

    # ==============================
    # 🔄 PATH & ENV REFRESH
    # ==============================
    _refresh_env() {
        # Reload PATH
        local paths=(
            "/usr/local/sbin"
            "/usr/local/bin"
            "/usr/sbin"
            "/usr/bin"
            "/sbin"
            "/bin"
            "${HOME}/.local/bin"
            "${HOME}/.bin"
            "${HOME}/.fzf/bin"
        )

        local new_path=""
        for p in "${paths[@]}"; do
            [[ -d "$p" ]] && new_path="${new_path:+$new_path:}$p"
        done

        # Preserve existing PATH entries not in our list
        local IFS=':'
        for p in ${=PATH}; do
            if [[ ":$new_path:" != *":$p:"* ]] && [[ -d "$p" ]]; then
                new_path="$new_path:$p"
            fi
        done
        unset IFS

        export PATH="$new_path"

        # Refresh hash table
        hash -r 2>/dev/null || true

        # Source bashrc if exists (for new completions)
        [[ -f "$HOME/.bashrc" ]] && source "$HOME/.bashrc" 2>/dev/null || true
    }

    # ==============================
    # 🛠️ TOOL INSTALLERS
    # ==============================
    _install_fzf() {
        echo -e "${YELLOW}⚠️  fzf not found. Installing...${NC}"

        # Try package manager first
        local pkg_name="fzf"

        # Some distros have different names
        case "$DISTRO_ID" in
            alpine) pkg_name="fzf" ;;
        esac

        if _pkg_install "$pkg_name"; then
            _configure_fzf
            return 0
        fi

        # Fallback: Git installation
        echo -e "${YELLOW}📥 Package manager failed. Trying git install...${NC}"

        if ! command -v git >/dev/null 2>&1; then
            _pkg_install "git" || {
                echo -e "${RED}❌ git not available${NC}" >&2
                return 1
            }
        fi

        local fzf_dir="${HOME}/.fzf"
        rm -rf "$fzf_dir" 2>/dev/null || true

        if git clone --depth 1 https://github.com/junegunn/fzf.git "$fzf_dir" 2>/dev/null; then
            "$fzf_dir/install" --all --no-bash --no-fish --no-zsh 2>/dev/null || true
            _configure_fzf
            return 0
        fi

        echo -e "${RED}❌ fzf installation failed${NC}" >&2
        return 1
    }

    _configure_fzf() {
        echo -e "${BLUE}🔧 Configuring fzf...${NC}"

        _refresh_env

        # Verify fzf is available
        if ! command -v fzf >/dev/null 2>&1; then
            # Manual PATH addition
            [[ -f "${HOME}/.fzf/bin/fzf" ]] && export PATH="${HOME}/.fzf/bin:$PATH"
            [[ -f "/usr/bin/fzf" ]] && export PATH="/usr/bin:$PATH"
        fi

        # Setup shell integration
        local bashrc="${HOME}/.bashrc"
        local fzf_shell=""

        # Find fzf shell files
        for d in "/usr/share/doc/fzf/examples" "/usr/share/fzf" "/usr/share/fzf/shell" "${HOME}/.fzf/shell"; do
            [[ -f "$d/completion.bash" ]] && fzf_shell="$d" && break
        done

        if [[ -n "$fzf_shell" ]] && [[ -f "$bashrc" ]]; then
            # Add to bashrc if not present
            if ! grep -q "fzf" "$bashrc" 2>/dev/null; then
                {
                    echo ""
                    echo "# fzf configuration added by uc-optimizer"
                    echo "source $fzf_shell/completion.bash 2>/dev/null || true"
                    echo "source $fzf_shell/key-bindings.bash 2>/dev/null || true"
                } >> "$bashrc"
            fi
        fi

        # Load immediately
        [[ -n "$fzf_shell" ]] && source "$fzf_shell/completion.bash" 2>/dev/null || true
        [[ -n "$fzf_shell" ]] && source "$fzf_shell/key-bindings.bash" 2>/dev/null || true

        # Final verification
        if command -v fzf >/dev/null 2>&1; then
            echo -e "${GREEN}✅ fzf $(fzf --version | head -1) installed${NC}"
            return 0
        else
            echo -e "${RED}❌ fzf configuration incomplete${NC}" >&2
            return 1
        fi
    }

    _install_sensors() {
        echo -e "${YELLOW}⚠️  sensors not found. Installing...${NC}"

        local pkg_name="lm-sensors"
        [[ "$DISTRO_ID" == "arch" || "$DISTRO_ID" == "manjaro" ]] && pkg_name="lm_sensors"
        [[ "$DISTRO_ID" == "alpine" ]] && pkg_name="lm-sensors"

        if ! _pkg_install "$pkg_name"; then
            echo -e "${RED}❌ lm-sensors installation failed${NC}" >&2
            return 1
        fi

        echo -e "${BLUE}🔧 Configuring sensors...${NC}"

        if ! command -v sensors-detect >/dev/null 2>&1; then
            echo -e "${YELLOW}⚠️  sensors-detect not found${NC}"
            return 0  # Partial success
        fi

        # Non-interactive configuration
        echo -e "${CYAN}🌡️  Detecting hardware sensors (this may take a moment)...${NC}"

        # ZSH FIX: C-style loop instead of {1..10}
        local answers=""
        local i
        for ((i=0; i<10; i++)); do
            answers="${answers}YES\n"
        done

        echo -e "$answers" | sudo sensors-detect --no-interactive 2>/dev/null || \
        echo -e "$answers" | sudo sensors-detect 2>/dev/null || true

        # Load common modules
        local modules=(coretemp nct6775 k10temp acpi_cpufreq it87)
        for mod in "${modules[@]}"; do
            sudo modprobe "$mod" 2>/dev/null || true
        done

        # Enable service
        if command -v systemctl >/dev/null 2>&1; then
            sudo systemctl enable --now lm-sensors 2>/dev/null || \
            sudo systemctl enable --now sensord 2>/dev/null || true
        fi

        # Generate sensors.conf if missing
        if [[ ! -f /etc/sensors3.conf ]] && [[ ! -f /etc/sensors.conf ]]; then
            sudo sensors -s 2>/dev/null || true
        fi

        # Test
        if sensors >/dev/null 2>&1; then
            echo -e "${GREEN}✅ sensors configured successfully${NC}"
        else
            echo -e "${YELLOW}⚠️  sensors configured but no sensors detected${NC}"
        fi

        return 0
    }

    _install_zram() {
        echo -e "${YELLOW}⚠️  zram tools not found. Installing...${NC}"

        local pkg_name="util-linux"
        local extra_pkgs=()

        case "$DISTRO_ID" in
            ubuntu|debian|linuxmint|pop)
                pkg_name="zram-tools"
                ;;
            fedora|rhel|centos|rocky)
                pkg_name="zram"
                ;;
            arch|manjaro|endeavouros)
                pkg_name="zram-generator"
                extra_pkgs=("util-linux")
                ;;
            alpine)
                pkg_name="zram-init"
                ;;
            opensuse*)
                pkg_name="systemd-zram-service"
                ;;
        esac

        if ! _pkg_install "$pkg_name" "${extra_pkgs[@]}"; then
            echo -e "${RED}❌ zram package installation failed${NC}" >&2
            return 1
        fi

        echo -e "${BLUE}🔧 Configuring zram...${NC}"

        # Check if zram already configured
        if [[ -e /dev/zram0 ]] && swapon -s 2>/dev/null | grep -q zram; then
            echo -e "${GREEN}✅ zram already active${NC}"
            return 0
        fi

        # Load module
        if ! lsmod 2>/dev/null | grep -q "^zram"; then
            sudo modprobe zram num_devices=1 2>/dev/null || {
                echo -e "${RED}❌ Cannot load zram module${NC}" >&2
                return 1
            }
        fi

        # Calculate size (50% of RAM)
        local mem_total zram_size
        mem_total=$(awk '/MemTotal/{print $2}' /proc/meminfo 2>/dev/null || echo "0")
        zram_size=$((mem_total * 512))  # KB to bytes / 2

        [[ "$zram_size" -lt 104857600 ]] && zram_size=536870912  # Minimum 512MB

        # Configure
        echo "$zram_size" | sudo tee /sys/block/zram0/disksize >/dev/null 2>/dev/null || {
            echo -e "${RED}❌ Cannot set zram size${NC}" >&2
            return 1
        }

        sudo mkswap /dev/zram0 >/dev/null 2>&1 || true
        sudo swapon /dev/zram0 -p 100 >/dev/null 2>&1 || {
            echo -e "${RED}❌ Cannot enable zram swap${NC}" >&2
            return 1
        }

        # Persistent config for systemd-based systems
        if [[ "$DISTRO_ID" == "arch" || "$DISTRO_ID" == "fedora" ]] && [[ -d /etc/systemd ]]; then
            local zram_conf="/etc/systemd/zram-generator.conf"
            if [[ ! -f "$zram_conf" ]]; then
                sudo tee "$zram_conf" >/dev/null <<'EOF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
EOF
            fi
        fi

        echo -e "${GREEN}✅ zram configured: $((zram_size / 1024 / 1024))MB${NC}"
        return 0
    }

    # ==============================
    # 🔍 DEPENDENCY CHECK
    # ==============================
    echo -e "${BLUE}🔍 Checking dependencies...${NC}"

    # ZSH FIX: Initialize arrays properly
    local missing_tools
    missing_tools=()
    local install_failed=0

    command -v fzf >/dev/null 2>&1 || missing_tools+=("fzf")
    command -v sensors >/dev/null 2>&1 || missing_tools+=("sensors")
    command -v zramctl >/dev/null 2>&1 || missing_tools+=("zram")

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo -e "${YELLOW}📋 Missing: ${missing_tools[*]}${NC}"
        echo -e "${CYAN}🚀 Installing...${NC}"
        echo ""

        for tool in "${missing_tools[@]}"; do
            case "$tool" in
                fzf)
                    if ! _install_fzf; then
                        install_failed=$((install_failed + 1))
                        echo -e "${RED}CRITICAL: fzf is required${NC}" >&2
                    fi
                    ;;
                sensors)
                    _install_sensors || install_failed=$((install_failed + 1))
                    ;;
                zram)
                    _install_zram || install_failed=$((install_failed + 1))
                    ;;
            esac
            echo ""
        done

        _refresh_env
    fi

    # Final verification
    local critical_fail=0
    if ! command -v fzf >/dev/null 2>&1; then
        echo -e "${RED}❌ CRITICAL: fzf not available${NC}" >&2
        critical_fail=1
    fi

    if ! command -v sensors >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  sensors not available (temp monitoring disabled)${NC}"
    fi

    if ! command -v zramctl >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  zramctl not available (zram monitoring disabled)${NC}"
    fi

    if [[ $critical_fail -eq 1 ]]; then
        echo -e "${RED}❌ Cannot continue without fzf${NC}" >&2
        _log "FAILED: Missing critical dependency fzf"
        return 1
    fi

    echo -e "${GREEN}✅ Dependencies ready!${NC}"
    _log "Dependencies satisfied"
    sleep 1
    clear

    # ==============================
    # 🔧 CORE FUNCTIONS
    # ==============================
    _pkg_clean() {
        _sudo_check || return 1
        case "$DISTRO_ID" in
            ubuntu|debian|linuxmint|pop|elementary)
                sudo apt-get autoremove --purge -y && sudo apt-get autoclean
                ;;
            fedora|rhel|centos|rocky|almalinux|nobara)
                if command -v dnf >/dev/null 2>&1; then
                    sudo dnf autoremove -y && sudo dnf clean all
                else
                    sudo yum autoremove -y && sudo yum clean all
                fi
                ;;
            arch|manjaro|endeavouros|garuda)
                sudo pacman -Sc --noconfirm
                command -v paccache >/dev/null 2>&1 && sudo paccache -r
                ;;
            opensuse*|suse*)
                sudo zypper clean
                ;;
            alpine)
                sudo apk cache clean
                ;;
            void)
                sudo xbps-remove -yo 2>/dev/null || true
                ;;
        esac
    }

    _get_temp_zram() {
        local temp="N/A" zram_used="0"

        if command -v sensors >/dev/null 2>&1; then
            temp=$(sensors 2>/dev/null | awk '
                /°C/ {
                    gsub(/[+|°C]/, "", $2)
                    if ($2+0 > max && $2 ~ /^[0-9]+\.?[0-9]*$/) max=$2
                }
                END {
                    if (max > 0) printf "%.0f", max
                    else print "N/A"
                }
            ')
        fi

        if command -v zramctl >/dev/null 2>&1; then
            zram_used=$(zramctl --output=DISKSIZE,DATA --bytes 2>/dev/null | awk '
                NR>1 {
                    if ($1 ~ /^[0-9]+$/ && $1 > 0) {
                        disk += $1
                        data += $2
                    }
                }
                END {
                    if (disk > 0) printf "%.0f", (data/disk)*100
                    else print "0"
                }
            ')
        fi

        printf '%s %s' "${temp:-N/A}" "${zram_used:-0}"
    }

    _get_free_kb() {
        local avail
        avail=$(df -k / 2>/dev/null | awk 'NR==2 {print $4}')
        [[ "$avail" =~ ^[0-9]+$ ]] && echo "$avail" || echo "0"
    }

    _format_size() {
        local kb=$1
        [[ "$kb" =~ ^[0-9]+$ ]] || { echo "0KB"; return; }

        local mb=$((kb / 1024))
        local gb=$((mb / 1024))

        if [[ $kb -lt 1024 ]]; then echo "${kb}KB"
        elif [[ $mb -lt 1024 ]]; then echo "${mb}MB"
        else echo "${gb}GB"
        fi
    }

    _run_task() {
        local label=$1
        shift
        echo -ne "   ${GREEN}➤ $label...${NC} "
        if "$@" >/dev/null 2>&1; then
            echo -e "${GREEN}✅${NC}"
            return 0
        else
            echo -e "${RED}❌${NC}"
            return 1
        fi
    }

    # ==============================
    # 🧹 CLEANING FUNCTIONS
    # ==============================
    _os_clean() {
        echo -e "${BLUE}╔════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}        ⚡ OS CLEAN             ${BLUE}║${NC}"
        echo -e "${BLUE}╚════════════════════════════════╝${NC}"

        # ZSH FIX: Separate prompt and read (read -p doesn't work in zsh)
        local confirm=""
        echo -n "Proceed with OS cleanup? [y/N]: "
        read -r confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || return 0

        _sudo_check || return 1

        echo -e "${CYAN}🗑️  Cleaning package cache...${NC}"
        _pkg_clean

        echo -e "${CYAN}📋 Vacuuming journals...${NC}"
        sudo journalctl --vacuum-time=3d --quiet 2>/dev/null || true

        echo -e "${CYAN}🖼️  Cleaning thumbnails...${NC}"
        if [[ -d "$HOME/.cache/thumbnails" ]]; then
            find "$HOME/.cache/thumbnails" -type f -atime +7 -delete 2>/dev/null || true
        fi

        echo -e "${CYAN}🗑️  Emptying trash...${NC}"
        if [[ -d "$HOME/.local/share/Trash/files" ]]; then
            rm -rf "$HOME/.local/share/Trash/files/"* 2>/dev/null || true
        fi
        if [[ -d "$HOME/.local/share/Trash/info" ]]; then
            rm -rf "$HOME/.local/share/Trash/info/"* 2>/dev/null || true
        fi

        # Clean old logs
        sudo find /var/log -type f -name "*.old" -delete 2>/dev/null || true
        sudo find /var/log -type f -name "*.gz" -mtime +30 -delete 2>/dev/null || true

        echo -e "${GREEN}✅ OS cleanup completed${NC}"
        _log "OS clean executed"
    }


    _container_clean() {
        echo -e "${BLUE}╔════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}      🐳 CONTAINER CLEAN        ${BLUE}║${NC}"
        echo -e "${BLUE}╚════════════════════════════════╝${NC}"

        # ZSH FIX: Separate prompt and read
        local confirm=""
        echo -n "Proceed with container cleanup? [y/N]: "
        read -r confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || return 0

        local total_saved=0

        # Snap cleanup
        if command -v snap >/dev/null 2>&1; then
            echo -e "${CYAN}📦 Cleaning snap packages...${NC}"
            local start_space end_space saved
            start_space=$(_get_free_kb)

            local snap_output
            snap_output=$(snap list --all 2>/dev/null | awk '/disabled/{print $1, $3}')

            if [[ -n "$snap_output" ]]; then
                while read -r name rev; do
                    [[ "$name" =~ ^[a-z0-9-]+$ ]] || continue
                    [[ "$rev" =~ ^[0-9]+$ ]] || continue
                    echo -e "   ${YELLOW}Removing: $name (rev $rev)${NC}"
                    sudo snap remove --revision="$rev" "$name" 2>/dev/null || true
                done <<< "$snap_output"
            fi

            sudo rm -rf /var/lib/snapd/cache/* 2>/dev/null || true

            end_space=$(_get_free_kb)
            saved=$(( (end_space - start_space) * 1024 ))
            [[ $saved -gt 0 ]] && total_saved=$((total_saved + saved))
            echo -e "   ${GREEN}Snap saved: $(_format_size $((saved / 1024)))${NC}"
        fi

        # Flatpak cleanup
        if command -v flatpak >/dev/null 2>&1; then
            echo -e "${CYAN}📦 Cleaning flatpak...${NC}"
            local start_space=$(_get_free_kb)

            flatpak uninstall --unused -y 2>/dev/null || true
            flatpak repair 2>/dev/null || true

            local end_space=$(_get_free_kb)
            local saved=$(( (end_space - start_space) * 1024 ))
            [[ $saved -gt 0 ]] && total_saved=$((total_saved + saved))
            echo -e "   ${GREEN}Flatpak saved: $(_format_size $((saved / 1024)))${NC}"
        fi

        # Docker cleanup
        if command -v docker >/dev/null 2>&1; then
            echo -e "${CYAN}🐳 Cleaning docker...${NC}"
            if sudo docker info >/dev/null 2>&1; then
                local start_space=$(_get_free_kb)

                docker system prune -a --volumes -f 2>/dev/null || true

                local end_space=$(_get_free_kb)
                local saved=$(( (end_space - start_space) * 1024 ))
                [[ $saved -gt 0 ]] && total_saved=$((total_saved + saved))
                echo -e "   ${GREEN}Docker saved: $(_format_size $((saved / 1024)))${NC}"
            else
                echo -e "   ${YELLOW}Docker daemon not running${NC}"
            fi
        fi

        # Podman cleanup
        if command -v podman >/dev/null 2>&1; then
            echo -e "${CYAN}🦭 Cleaning podman...${NC}"
            podman system prune -f 2>/dev/null || true
            echo -e "   ${GREEN}Podman cleaned${NC}"
        fi

        echo -e "${GREEN}✅ Total saved: $(_format_size $((total_saved / 1024)))${NC}"
        _log "Container clean executed"
    }

    _fix_links() {
        echo -e "${BLUE}╔════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}        🔗 FIX LINKS            ${BLUE}║${NC}"
        echo -e "${BLUE}╚════════════════════════════════╝${NC}"

        # ZSH FIX: Separate prompt and read
        local confirm=""
        echo -n "Remove broken symlinks in $HOME? [y/N]: "
        read -r confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || return 0

        local count=0
        while IFS= read -r -d '' link; do
            rm -f "$link" 2>/dev/null && ((count++)) || true
        done < <(find "$HOME" -xdev -maxdepth 3 -xtype l -print0 2>/dev/null)

        echo -e "${GREEN}✅ Removed $count broken symlinks${NC}"
        _log "Fixed $count broken links"
    }

    _orphan_engine() {
        echo -e "${BLUE}╔════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}       ⚡ KERNEL CLEAN           ${BLUE}║${NC}"
        echo -e "${BLUE}╚════════════════════════════════╝${NC}"

        local current_kernel
        current_kernel=$(uname -r)
        echo -e "Current kernel: ${GREEN}$current_kernel${NC}"

        _sudo_check || return 1

        case "$DISTRO_ID" in
            ubuntu|debian|linuxmint|pop|elementary)
                local kernels=()
                while IFS= read -r line; do
                    kernels+=("$line")
                done < <(dpkg-query -W -f='${Package}\n' 2>/dev/null | grep -E '^linux-image-[0-9]' | sort -V)

                if [[ ${#kernels[@]} -le 2 ]]; then
                    echo -e "${GREEN}Only ${#kernels[@]} kernels installed, skipping${NC}"
                    return 0
                fi

                local keep1="${kernels[-1]}"
                local keep2="${kernels[-2]}"
                echo -e "Keeping: ${GREEN}$keep1${NC} and ${GREEN}$keep2${NC}"

                local to_remove=()
                for k in "${kernels[@]}"; do
                    if [[ "$k" != "$keep1" && "$k" != "$keep2" && "$k" != *"$current_kernel"* ]]; then
                        to_remove+=("$k")
                    fi
                done

                if [[ ${#to_remove[@]} -gt 0 ]]; then
                    echo -e "${YELLOW}Will remove: ${to_remove[*]}${NC}"
                    # ZSH FIX: Separate prompt and read
                    local confirm2=""
                    echo -n "Confirm? [y/N]: "
                    read -r confirm2
                    if [[ "$confirm2" =~ ^[Yy]$ ]]; then
                        sudo apt-get purge -y "${to_remove[@]}" 2>/dev/null || true
                        sudo apt-get autoremove -y 2>/dev/null || true
                    fi
                fi

                # Remove residual configs
                local residual
                residual=$(dpkg-query -W -f='${Package}\n' 2>/dev/null | grep '^rc' || true)
                if [[ -n "$residual" ]]; then
                    echo "$residual" | xargs -r sudo dpkg --purge 2>/dev/null || true
                fi
                ;;

            fedora|rhel|centos|rocky|almalinux|nobara)
                if command -v dnf >/dev/null 2>&1; then
                    echo -e "${CYAN}Removing old kernels...${NC}"
                    sudo dnf remove --oldinstallonly --setopt installonly_limit=2 -y 2>/dev/null || {
                        # Fallback manual method
                        local old_kernels
                        old_kernels=$(dnf repoquery --installonly --latest-limit=-2 -q 2>/dev/null | grep -v "$current_kernel" || true)
                        if [[ -n "$old_kernels" ]]; then
                            echo "$old_kernels" | xargs -r sudo dnf remove -y 2>/dev/null || true
                        fi
                    }
                fi
                ;;

            arch|manjaro|endeavouros|garuda|cachyos)
                echo -e "${CYAN}Removing orphan packages...${NC}"
                local orphans
                orphans=$(pacman -Qtdq 2>/dev/null || true)
                if [[ -n "$orphans" ]]; then
                    echo "$orphans" | sudo pacman -Rns --noconfirm - 2>/dev/null || true
                fi

                if command -v paccache >/dev/null 2>&1; then
                    echo -e "${CYAN}Cleaning package cache...${NC}"
                    sudo paccache -rk2 2>/dev/null || true
                fi
                ;;

            opensuse*)
                echo -e "${CYAN}Cleaning kernels...${NC}"
                sudo zypper purge-kernels 2>/dev/null || true
                ;;

            *)
                echo -e "${YELLOW}⚠️  Kernel cleanup not implemented for $DISTRO_ID${NC}"
                ;;
        esac

        echo -e "${GREEN}✅ Kernel cleanup completed${NC}"
        _log "Kernel clean executed"
    }

    _ai_mode() {
        echo -e "${BLUE}╔════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}       🤖 AI DIAGNOSTICS        ${BLUE}║${NC}"
        echo -e "${BLUE}╚════════════════════════════════╝${NC}"

        # Get system stats
        local mem_info
        mem_info=$(free -k 2>/dev/null | awk '/^Mem:/{printf "%.0f %.0f %.0f", $2, $3, ($3/$2)*100}')
        if [[ -z "$mem_info" ]]; then
            mem_info="0 0 0"
        fi
        local mem_total mem_used mem_pct
        read -r mem_total mem_used mem_pct <<< "$mem_info"
        mem_total=${mem_total:-0}
        mem_used=${mem_used:-0}
        mem_pct=${mem_pct:-0}
        # Sanitize: strip anything that isn't a digit (handles floats / empty)
        mem_pct=$(( ${mem_pct//[^0-9]/} + 0 ))

        local disk_info
        disk_info=$(df -k / 2>/dev/null | awk 'NR==2{print $3, $4, $5}')
        if [[ -z "$disk_info" ]]; then
            disk_info="0 0 0%"
        fi
        local disk_used disk_avail disk_pct
        read -r disk_used disk_avail disk_pct <<< "$disk_info"
        disk_used=${disk_used:-0}
        disk_avail=${disk_avail:-0}
        disk_pct=${disk_pct:-0%}
        disk_pct="${disk_pct//%/}"
        # Sanitize: strip non-digits so arithmetic is always safe
        disk_pct=$(( ${disk_pct//[^0-9]/} + 0 ))

        local temp="N/A" zram_used="0"
        read -r temp zram_used < <(_get_temp_zram)
        temp=${temp:-N/A}
        zram_used=${zram_used:-0}

        # Display
        echo -e "📊 ${CYAN}System Status:${NC}"
        echo -e "   Memory: ${mem_pct}% used ($((mem_used/1024))MB / $((mem_total/1024))MB)"
        echo -e "   Disk:   ${disk_pct}% used ($(_format_size $((disk_used/1024))) / $(_format_size $(( (disk_used+disk_avail)/1024 ))))"
        echo -e "   Temp:   ${temp}°C"
        echo -e "   ZRAM:   ${zram_used}% used"

        # AI Recommendations
        local actions=()

        if [[ "$mem_pct" -gt 85 ]]; then
            echo -e "\n${YELLOW}⚠️  HIGH MEMORY USAGE${NC}"
            # ZSH FIX: Separate prompt and read
            local confirm=""
            echo -n "   Drop caches? [y/N]: "
            read -r confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                _sudo_check && {
                    sudo sync
                    echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null 2>&1 || true
                    echo -e "   ${GREEN}✅ Caches dropped${NC}"
                }
            fi
        fi

        if [[ "$disk_pct" -gt 90 ]]; then
            echo -e "\n${RED}🚨 CRITICAL DISK USAGE${NC}"
            _os_clean
        elif [[ "$disk_pct" -gt 80 ]]; then
            echo -e "\n${YELLOW}⚠️  High disk usage${NC}"
            # ZSH FIX: Separate prompt and read
            local confirm=""
            echo -n "   Run OS cleanup? [y/N]: "
            read -r confirm
            [[ "$confirm" =~ ^[Yy]$ ]] && _os_clean
        fi

        # ZSH FIX: Split into two checks — combining != and -gt in one [[...]] can
        # trigger "bad math expression" when temp is "N/A" or a non-integer string.
        if [[ "$temp" != "N/A" ]]; then
            local temp_int=$(( ${temp//[^0-9]/} + 0 ))
            if [[ $temp_int -gt 80 ]]; then
                echo -e "\n${RED}🌡️  HIGH TEMPERATURE${NC}"
                echo -e "   ${YELLOW}Check cooling system!${NC}"
            fi
        fi

        _log "AI mode executed"
    }

    _report() {
        echo -e "${BLUE}╔════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}       📊 SYSTEM REPORT         ${BLUE}║${NC}"
        echo -e "${BLUE}╚════════════════════════════════╝${NC}"

        echo -e "${CYAN}OS Information:${NC}"
        echo -e "   Distribution: $DISTRO_NAME"
        echo -e "   Kernel:       $(uname -r)"
        echo -e "   Architecture: $(uname -m)"
        echo -e "   Hostname:     $(hostname)"

        local uptime_str
        uptime_str=$(uptime -p 2>/dev/null || uptime | sed 's/.*up \([^,]*\),.*/\1/')
        echo -e "   Uptime:       $uptime_str"

        echo -e "\n${CYAN}Resources:${NC}"

        # Memory
        free -h | awk '/Mem:/{printf "   Memory:       %s / %s (%.1f%% used)\n", $3, $2, ($3/$2)*100}'

        # Disk
        df -h / | awk 'NR==2{printf "   Disk (/):     %s / %s (%s used)\n", $3, $2, $5}'

        # Temperature & ZRAM
        local temp zram_used
        read -r temp zram_used < <(_get_temp_zram)
        echo -e "   Temperature:  ${temp}°C"
        echo -e "   ZRAM Usage:   ${zram_used}%"

        # CPU
        echo -e "   CPU:          $(nproc) cores"
        if [[ -r /proc/cpuinfo ]]; then
            local cpu_model
            cpu_model=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs | cut -c1-40)
            echo -e "   Model:        $cpu_model"
        fi

        # Load average
        echo -e "   Load:         $(cut -d' ' -f1-3 /proc/loadavg 2>/dev/null || echo 'N/A')"

        echo -e "\n${CYAN}Top Processes (by memory):${NC}"
        ps aux --sort=-%mem 2>/dev/null | head -6 | tail -5 | awk '{printf "   %-10s %5s%% %s\n", $1, $4, $11}'

        _log "Report generated"
    }

    # ==============================
    # 📋 INTERACTIVE MENU
    # ==============================
    _show_menu() {
        # ZSH FIX: Initialize array properly
        local choices
        choices=(
            "🚀  Full System Boost"
            "🤖  AI Smart Cleanup"
            "⚡  OS Clean"
            "🐳  Container Clean"
            "🔗  Fix Broken Links"
            "⚡  Kernel Clean"
            "📊  System Report"
            "❌  Exit"
        )

        local choice
        choice=$(printf "%s\n" "${choices[@]}" | \
            fzf --height=70% \
                --layout=reverse \
                --border=rounded \
                --border-label=" System Optimizer v3.0 " \
                --prompt="[$DISTRO_ID] ❯ " \
                --header="Use ↑↓ to navigate, Enter to select, Ctrl+C to quit" \
                --pointer="▶" \
                --marker="✓" \
                --ansi \
                --no-info \
                --cycle)

        [[ -z "$choice" ]] && return 1

        # Extract action (remove emoji and padding)
        local action="${choice#*[[:space:]]}"
        action="${action#*[[:space:]]}"

        case "$action" in
            "Full System Boost")
                _os_clean
                _container_clean
                _fix_links
                _orphan_engine
                _ai_mode
                _report
                ;;
            "AI Smart Cleanup") _ai_mode ;;
            "OS Clean") _os_clean ;;
            "Container Clean") _container_clean ;;
            "Fix Broken Links") _fix_links ;;
            "Kernel Clean") _orphan_engine ;;
            "System Report") _report ;;
            "Exit") return 0 ;;
            *)
                echo -e "${RED}Unknown option: $action${NC}" >&2
                return 1
                ;;
        esac

        return 0
    }

    # ==============================
    # 🎯 MAIN EXECUTION
    # ==============================
    local menu_result=0

    while true; do
        echo ""
        if ! _show_menu; then
            menu_result=1
            break
        fi

        echo ""
        # ZSH FIX: Separate prompt and read
        echo -n "Press Enter to continue..."
        read -r dummy </dev/tty
        clear
    done

    trap - INT TERM EXIT
    _log "Session ended (result: $menu_result)"
    echo -e "${GREEN}👋 Goodbye!${NC}"

    return $menu_result
}



# ======================================================
#  📦 runtime install
# ======================================================



rt() {
    # ১. fzf চেক এবং অটো-ইন্সটলেশন
    if ! command -v fzf &> /dev/null; then
        echo "🔍 fzf খুঁজে পাওয়া যায়নি। ইন্সটল করা হচ্ছে..."

        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux (Debian/Ubuntu) এর জন্য
            sudo apt update && sudo apt install fzf -y
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS এর জন্য (Homebrew প্রয়োজন)
            if command -v brew &> /dev/null; then
                brew install fzf
            else
                echo "❌ Error: Homebrew পাওয়া যায়নি। অনুগ্রহ করে fzf ম্যানুয়ালি ইন্সটল করুন।"
                return 1
            fi
        else
            echo "❌ দুঃখিত, আপনার অপারেটিং সিস্টেমটি অটো-ইন্সটলেশন সাপোর্ট করছে না।"
            return 1
        fi

        echo "✅ fzf ইন্সটলেশন সম্পন্ন হয়েছে!"
    fi

    # ২. মেনু অপশন
    options=(
        "NVM (Node Version Manager)"
        "Node.js (LTS Version)"
        "Bun (Fast JS Runtime)"
        "Deno (Secure JS Runtime)"
    )

    selected=$(printf "%s\n" "${options[@]}" | fzf \
        --header="🚀 Ultimate Tool Installer (q to Exit)" \
        --reverse --height=40% --border --bind 'q:abort')

    # ৩. সিলেকশন চেক
    if [ $? -ne 0 ] || [ -z "$selected" ]; then
        echo "👋 বিদায়!"
        return 0
    fi

    # ৪. টুল ইন্সটলেশন লজিক
    case "$selected" in
        "NVM (Node Version Manager)")
            if [ -d "$HOME/.nvm" ]; then
                echo "✅ NVM আগে থেকেই আছে।"
            else
                curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
                export NVM_DIR="$HOME/.nvm"
                [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            fi
            ;;
        "Node.js (LTS Version)")
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            if command -v nvm &> /dev/null; then
                nvm install --lts && nvm use --lts
            else
                echo "❌ আগে NVM ইন্সটল করুন!"
            fi
            ;;
        "Bun (Fast JS Runtime)")
            command -v bun &> /dev/null && echo "✅ Bun আছে: $(bun -v)" || (curl -fsSL https://bun.sh/install | bash && export PATH="$HOME/.bun/bin:$PATH")
            ;;
        "Deno (Secure JS Runtime)")
            command -v deno &> /dev/null && echo "✅ Deno আছে: $(deno -v)" || (curl -fsSL https://deno.land/x/install/install.sh | sh && export PATH="$HOME/.deno/bin:$PATH")
            ;;
    esac
}


# =========================================
# Ultimate Smart PC Optimizer (v5.1 - Clean UI)
# =========================================


ut() {
    # ===== 🎨 UI PALETTE =====
    local RED='\033[1;31m' GREEN='\033[1;32m' YELLOW='\033[1;33m'
    local BLUE='\033[1;34m' PURPLE='\033[1;35m' CYAN='\033[1;36m'
    local WHITE='\033[1;37m' BOLD='\033[1m' DIM='\033[2m' NC='\033[0m'
    local LOGFILE="/tmp/pcop_$(whoami)_$$.log"
    : > "$LOGFILE"

    # ===== 🖥️ DISTRO DETECTION =====
    local DISTRO_ID="" PKG_MANAGER="" PKG_INSTALL="" PKG_QUERY=""
    local SERVICE_CMD="systemctl"

    detect_distro() {
        if [[ -f /etc/os-release ]]; then
            source /etc/os-release
            DISTRO_ID=$(echo "$ID" | tr '[:upper:]' '[:lower:]')
        else
            echo -e "${RED}❌ Cannot detect distribution${NC}" && return 1
        fi

        case "$DISTRO_ID" in
            ubuntu|deepin|debian|linuxmint|pop|elementary|zorin|kali|parrot)
                PKG_MANAGER="apt"
                PKG_INSTALL="sudo apt install -y"
                PKG_QUERY="dpkg-query -W -f='${Status}'"
                ;;
            fedora|rhel|centos|rocky|almalinux|nobara)
                PKG_MANAGER="dnf"
                [[ "$DISTRO_ID" == "centos" ]] && [[ -z "$(command -v dnf)" ]] && PKG_MANAGER="yum"
                PKG_INSTALL="sudo $PKG_MANAGER install -y"
                PKG_QUERY="rpm -q"
                ;;
            arch|manjaro|endeavouros|garuda|cachyos|artix)
                PKG_MANAGER="pacman"
                PKG_INSTALL="sudo pacman -S --noconfirm --needed"
                PKG_QUERY="pacman -Q"
                ;;
            opensuse*|suse*)
                PKG_MANAGER="zypper"
                PKG_INSTALL="sudo zypper install -y"
                PKG_QUERY="rpm -q"
                ;;
            alpine)
                PKG_MANAGER="apk"
                PKG_INSTALL="sudo apk add"
                PKG_QUERY="apk info -e"
                SERVICE_CMD="rc-service"
                ;;
            void)
                PKG_MANAGER="xbps"
                PKG_INSTALL="sudo xbps-install -y"
                PKG_QUERY="xbps-query"
                SERVICE_CMD="sv"
                ;;
            *)
                echo -e "${YELLOW}⚠️ Unknown distro. Trying apt...${NC}"
                PKG_MANAGER="apt"
                PKG_INSTALL="sudo apt install -y"
                PKG_QUERY="dpkg-query -W -f='${Status}'"
                ;;
        esac
    }

    detect_distro || return 1
    echo -e "${CYAN} 🖥️  Detected: ${BOLD}${DISTRO_ID}${NC} | Package Manager: ${BOLD}${PKG_MANAGER}${NC}"

    # ===== ⚙️ FZF CHECK =====
    install_fzf_universal() {
        echo -e "${YELLOW}📦 Installing fzf...${NC}"
        case "$PKG_MANAGER" in
            "apt") sudo apt update -y && sudo apt install -y fzf ;;
            "dnf"|"yum") sudo $PKG_MANAGER install -y fzf ;;
            "pacman") sudo pacman -S --noconfirm fzf ;;
            "zypper") sudo zypper install -y fzf ;;
            "apk") sudo apk add fzf ;;
            "xbps") sudo xbps-install -y fzf ;;
            *)
                local FZF_VERSION=$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' || echo "0.54.0")
                curl -Lo /tmp/fzf.tar.gz "https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz"
                tar -xzf /tmp/fzf.tar.gz -C /tmp && sudo mv /tmp/fzf /usr/local/bin/
                rm -f /tmp/fzf.tar.gz
                ;;
        esac
        rehash 2>/dev/null || hash -r 2>/dev/null || true
    }

    local FZF_CMD=""
    FZF_CMD=$(whence -p fzf 2>/dev/null)
    [[ -z "$FZF_CMD" ]] && FZF_CMD=$(command -v fzf 2>/dev/null)
    [[ -z "$FZF_CMD" ]] && FZF_CMD=$(command -v fzf 2>/dev/null)

    if [[ -z "$FZF_CMD" ]]; then
        install_fzf_universal
        FZF_CMD=$(whence -p fzf 2>/dev/null)
        [[ -z "$FZF_CMD" ]] && FZF_CMD=$(command -v fzf 2>/dev/null)
        [[ -z "$FZF_CMD" ]] && FZF_CMD=$(command -v fzf 2>/dev/null)
    fi

    if [[ -z "$FZF_CMD" ]] || [[ ! -x "$FZF_CMD" ]]; then
        echo -e "${RED}❌ fzf installation failed${NC}"
        return 1
    fi

    # ===== 📦 PACKAGE DATABASE =====
    typeset -A PKG_MAP
    PKG_MAP[zram-tools]="zram-tools|zram-generator-defaults|zram-generator|systemd-zram-service|zram-tools|zramctl"
    PKG_MAP[earlyoom]="earlyoom|earlyoom|earlyoom|earlyoom|earlyoom|earlyoom"
    PKG_MAP[htop]="htop|htop|htop|htop|htop|htop"
    PKG_MAP[btop]="btop|btop|btop|btop|btop|btop"
    PKG_MAP[ncdu]="ncdu|ncdu|ncdu|ncdu|ncdu|ncdu"
    PKG_MAP[gdu]="gdu|gdu-disk-usage-analyzer|gdu|gdu|gdu|gdu"
    PKG_MAP[duf]="duf|duf|duf|duf|duf|duf"
    PKG_MAP[dust]="dust|dust|dust|du-dust|dust|dust"
    PKG_MAP[bleachbit]="bleachbit|bleachbit|bleachbit|bleachbit|bleachbit|bleachbit"
    PKG_MAP[ufw]="ufw|ufw|ufw|ufw|ufw|ufw"
    PKG_MAP[fail2ban]="fail2ban|fail2ban|fail2ban|fail2ban|fail2ban|fail2ban"
    PKG_MAP[rkhunter]="rkhunter|rkhunter|rkhunter|rkhunter|rkhunter|rkhunter"
    PKG_MAP[lynis]="lynis|lynis|lynis|lynis|lynis|lynis"
    PKG_MAP[clamav]="clamav|clamav|clamav|clamav|clamav|clamav"
    PKG_MAP[firejail]="firejail|firejail|firejail|firejail|firejail|firejail"
    PKG_MAP[gnupg]="gnupg2|gnupg2|gnupg|gpg2|gnupg|gnupg"
    PKG_MAP[speedtest-cli]="speedtest-cli|speedtest-cli|speedtest-cli|speedtest|speedtest-cli|speedtest-cli"
    PKG_MAP[vnstat]="vnstat|vnstat|vnstat|vnstat|vnstat|vnstat"
    PKG_MAP[nmap]="nmap|nmap|nmap|nmap|nmap|nmap"
    PKG_MAP[iftop]="iftop|iftop|iftop|iftop|iftop|iftop"
    PKG_MAP[nload]="nload|nload|nload|nload|nload|nload"
    PKG_MAP[nethogs]="nethogs|nethogs|nethogs|nethogs|nethogs|nethogs"
    PKG_MAP[curl]="curl|curl|curl|curl|curl|curl"
    PKG_MAP[wget]="wget|wget|wget|wget|wget|wget"
    PKG_MAP[aria2]="aria2|aria2|aria2|aria2|aria2|aria2"
    PKG_MAP[wireguard]="wireguard|wireguard-tools|wireguard-tools|wireguard-tools|wireguard-tools|wireguard"
    PKG_MAP[dog]="dog|dog|dog|dog|dog|dog"
    PKG_MAP[mtr-tiny]="mtr-tiny|mtr|mtr|mtr|mtr|mtr"
    PKG_MAP[tcpdump]="tcpdump|tcpdump|tcpdump|tcpdump|tcpdump|tcpdump"
    PKG_MAP[git]="git|git|git|git|git|git"
    PKG_MAP[docker.io]="docker.io|docker|docker|docker|docker|docker"
    PKG_MAP[docker-compose]="docker-compose|docker-compose|docker-compose|docker-compose|docker-compose|docker-compose"
    PKG_MAP[build-essential]="build-essential|gcc-c++|base-devel|patterns-devel-base-devel|build-base|base-devel"
    PKG_MAP[micro]="micro|micro|micro|micro|micro|micro"
    PKG_MAP[neovim]="neovim|neovim|neovim|neovim|neovim|neovim"
    PKG_MAP[tmux]="tmux|tmux|tmux|tmux|tmux|tmux"
    PKG_MAP[screen]="screen|screen|screen|screen|screen|screen"
    PKG_MAP[python3-pip]="python3-pip|python3-pip|python-pip|python3-pip|py3-pip|python3-pip"
    PKG_MAP[nodejs]="nodejs|nodejs|nodejs|nodejs|nodejs|nodejs"
    PKG_MAP[npm]="npm|npm|npm|npm|npm|npm"
    PKG_MAP[golang-go]="golang-go|golang|go|go|go|go"
    PKG_MAP[rsync]="rsync|rsync|rsync|rsync|rsync|rsync"
    PKG_MAP[jq]="jq|jq|jq|jq|jq|jq"
    PKG_MAP[yq]="yq|yq|yq|yq|yq|yq"
    PKG_MAP[bat]="bat|bat|bat|bat|bat|bat"
    PKG_MAP[eza]="eza|eza|eza|eza|eza|eza"
    PKG_MAP[ripgrep]="ripgrep|ripgrep|ripgrep|ripgrep|ripgrep|ripgrep"
    PKG_MAP[fd-find]="fd-find|fd-find|fd|fd|fd|fd"
    PKG_MAP[zoxide]="zoxide|zoxide|zoxide|zoxide|zoxide|zoxide"
    PKG_MAP[procs]="procs|procs|procs|procs|procs|procs"
    PKG_MAP[tldr]="tldr|tldr|tldr|tldr|tldr|tldr"
    PKG_MAP[chafa]="chafa|chafa|chafa|chafa|chafa|chafa"
    PKG_MAP[fzf]="fzf|fzf|fzf|fzf|fzf|fzf"
    PKG_MAP[fastfetch]="fastfetch|fastfetch|fastfetch|fastfetch|fastfetch|fastfetch"
    PKG_MAP[inxi]="inxi|inxi|inxi|inxi|inxi|inxi"
    PKG_MAP[lm-sensors]="lm-sensors|lm_sensors|lm_sensors|sensors|lm-sensors|lm-sensors"
    PKG_MAP[unzip]="unzip|unzip|unzip|unzip|unzip|unzip"
    PKG_MAP[p7zip-full]="p7zip-full|p7zip|p7zip|p7zip|p7zip|p7zip"
    PKG_MAP[zsh]="zsh|zsh|zsh|zsh|zsh|zsh"
    PKG_MAP[xclip]="xclip|xclip|xclip|xclip|xclip|xclip"
    PKG_MAP[wl-clipboard]="wl-clipboard|wl-clipboard|wl-clipboard|wl-clipboard|wl-clipboard|wl-clipboard"
    PKG_MAP[acpi]="acpi|acpi|acpi|acpi|acpi|acpi"
    PKG_MAP[sysstat]="sysstat|sysstat|sysstat|sysstat|sysstat|sysstat"
    PKG_MAP[stress-ng]="stress-ng|stress-ng|stress-ng|stress-ng|stress-ng|stress-ng"
    PKG_MAP[smem]="smem|smem|smem|smem|smem|smem"
    PKG_MAP[preload]="preload|preloader|preload|preloader|preload|preload"
    PKG_MAP[cpufrequtils]="cpufrequtils|cpufrequtils|cpupower|cpufrequtils|cpufrequtils|cpufrequtils"
    PKG_MAP[gparted]="gparted|gparted|gparted|gparted|gparted|gparted"
    PKG_MAP[smartmontools]="smartmontools|smartmontools|smartmontools|smartmontools|smartmontools|smartmontools"
    PKG_MAP[tree]="tree|tree|tree|tree|tree|tree"
    PKG_MAP[ranger]="ranger|ranger|ranger|ranger|ranger|ranger"
    PKG_MAP[mc]="mc|mc|mc|mc|mc|mc"
    PKG_MAP[glances]="glances|glances|glances|glances|glances|glances"
    PKG_MAP[atop]="atop|atop|atop|atop|atop|atop"
    PKG_MAP[gh]="gh|gh|github-cli|gh|github-cli|github-cli"
    PKG_MAP[lazygit]="lazygit|lazygit|lazygit|lazygit|lazygit|lazygit"
    PKG_MAP[lazydocker]="lazydocker|lazydocker|lazydocker|lazydocker|lazydocker|lazydocker"
    PKG_MAP[httpie]="httpie|httpie|httpie|httpie|httpie|httpie"
    PKG_MAP[stow]="stow|stow|stow|stow|stow|stow"
    PKG_MAP[lsof]="lsof|lsof|lsof|lsof|lsof|lsof"
    PKG_MAP[dnsutils]="dnsutils|bind-utils|bind|bind-utils|bind-tools|bind-tools"
    PKG_MAP[shellcheck]="shellcheck|ShellCheck|shellcheck|ShellCheck|shellcheck|shellcheck"
    PKG_MAP[shfmt]="shfmt|shfmt|shfmt|shfmt|shfmt|shfmt"
    PKG_MAP[socat]="socat|socat|socat|socat|socat|socat"
    PKG_MAP[strace]="strace|strace|strace|strace|strace|strace"
    PKG_MAP[git-delta]="git-delta|git-delta|git-delta|git-delta|git-delta|git-delta"
    PKG_MAP[iputils-ping]="iputils-ping|iputils|iputils|iputils|iputils|iputils"
    PKG_MAP[net-tools]="net-tools|net-tools|net-tools|net-tools|net-tools|net-tools"

    get_pkg_name() {
        local generic="$1"
        local mapping="${PKG_MAP[$generic]}"
        [[ -z "$mapping" ]] && echo "$generic" && return
        local idx=1
        case "$PKG_MANAGER" in
            "apt") idx=1 ;;
            "dnf"|"yum") idx=2 ;;
            "pacman") idx=3 ;;
            "zypper") idx=4 ;;
            "apk") idx=5 ;;
            "xbps") idx=6 ;;
        esac
        echo "$mapping" | cut -d'|' -f$idx
    }

    is_installed() {
        local pkg="$1"
        case "$PKG_MANAGER" in
            "apt") dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "ok installed" ;;
            "dnf"|"yum"|"zypper") rpm -q "$pkg" &>/dev/null ;;
            "pacman") pacman -Q "$pkg" &>/dev/null ;;
            "apk") apk info -e "$pkg" &>/dev/null ;;
            "xbps") xbps-query "$pkg" &>/dev/null ;;
            *) return 1 ;;
        esac
    }

    # ===== 🎨 RENDER ENGINE WITH INDEX =====
    local menu_items
    menu_items=()

    local tool_list=(
        "PERF|zram-tools|RAM optimization using zRAM"
        "PERF|earlyoom|Prevent system freeze when RAM is low"
        "PERF|htop|Classic interactive process monitor"
        "PERF|btop|Modern & beautiful resource dashboard"
        "PERF|glances|Full system statistics at a glance"
        "PERF|atop|Advanced system & process monitor"
        "PERF|sysstat|System performance tools (sar, iostat)"
        "PERF|stress-ng|Stress test your CPU/RAM/IO"
        "PERF|smem|Report memory usage with PSS/USS"
        "PERF|preload|Adaptive readahead daemon (Speed up apps)"
        "PERF|cpufrequtils|CPU frequency scaling utilities"
        "DISK|ncdu|Disk usage analyzer (NCurses)"
        "DISK|gdu|Fast disk usage analyzer (Go based)"
        "DISK|duf|Visual Disk Usage/Free utility"
        "DISK|dust|A more intuitive version of 'du' in Rust"
        "DISK|bleachbit|Clean system junk and maintain privacy"
        "DISK|stacer|All-in-one system optimizer & GUI"
        "DISK|gparted|GNOME Partition Editor"
        "DISK|smartmontools|Control & monitor SMART storage systems"
        "DISK|tree|List contents of directories in a tree-like format"
        "DISK|ranger|VIM-inspired file manager for terminal"
        "DISK|mc|Midnight Commander (Twin-panel file manager)"
        "SECURE|ufw|Uncomplicated Firewall"
        "SECURE|fail2ban|Protect against brute-force attacks"
        "SECURE|rkhunter|Rootkit and exploit scanner"
        "SECURE|chkrootkit|Locally check for signs of a rootkit"
        "SECURE|lynis|Security auditing tool for Linux"
        "SECURE|clamav|Open source antivirus engine"
        "SECURE|firejail|Sandbox security for applications"
        "SECURE|gnupg|Gnu Privacy Guard for encryption"
        "NET|speedtest-cli|Test internet bandwidth via CLI"
        "NET|vnstat|Console-based network traffic monitor"
        "NET|nmap|Network exploration & security auditing"
        "NET|iftop|Display bandwidth usage on an interface"
        "NET|nload|Real-time network traffic visualization"
        "NET|nethogs|Net usage per process (Top for network)"
        "NET|curl|Command line tool for transferring data"
        "NET|wget|Retrieve files using HTTP, HTTPS, FTP"
        "NET|aria2|High-speed multi-source download utility"
        "NET|wireguard|Fast, modern and secure VPN tunnel"
        "NET|dog|A command-line DNS client (Better dig)"
        "NET|mtr-tiny|Combined ping and traceroute tool"
        "NET|tcpdump|Powerful command-line packet analyzer"
        "DEV|git|Distributed version control system"
        "DEV|docker.io|OS-level virtualization (Docker)"
        "DEV|docker-compose|Define & run multi-container applications"
        "DEV|build-essential|Essential packages for compiling code"
        "DEV|micro|Modern and intuitive terminal-based editor"
        "DEV|neovim|Extensible text editor (Vim 2.0)"
        "DEV|tmux|Terminal multiplexer for managing sessions"
        "DEV|screen|Full-screen window manager/multiplexer"
        "DEV|python3-pip|The Python package installer"
        "DEV|nodejs|JavaScript runtime environment"
        "DEV|npm|The Node.js package manager"
        "DEV|golang-go|The Go programming language"
        "DEV|rsync|Fast, versatile remote/local file-copy"
        "DEV|jq|Command-line JSON processor"
        "DEV|yq|Command-line YAML/XML processor"
        "MODERN|bat|Cat clone with syntax highlighting"
        "MODERN|eza|Modern replacement for 'ls' with icons"
        "MODERN|ripgrep|Extremely fast grep alternative"
        "MODERN|fd-find|Simple, fast alternative to 'find'"
        "MODERN|zoxide|Smarter cd command (Learns your habits)"
        "MODERN|procs|Modern replacement for 'ps' in Rust"
        "MODERN|tldr|Simplified community-driven man pages"
        "MODERN|chafa|Terminal graphics for the 21st century"
        "MODERN|fzf|General-purpose fuzzy finder"
        "SYS|fastfetch|High-performance neofetch alternative"
        "SYS|inxi|Full-featured system information script"
        "SYS|lm-sensors|Read temperature/voltage/fan sensors"
        "SYS|unzip|Decompress zip files"
        "SYS|p7zip-full|7z file archiver with high compression"
        "SYS|zsh|The Z shell (Advanced bash alternative)"
        "SYS|xclip|Command line interface to X selections"
        "SYS|wl-clipboard|Command line copy/paste for Wayland"
        "SYS|acpi|Displays battery and thermal information"
    )

    local idx=0
    for item in "${tool_list[@]}"; do
        idx=$(( idx + 1 ))
        local cat="" generic="" desc=""
        IFS='|' read -r cat generic desc <<< "$item"
        local pkg=$(get_pkg_name "$generic")

        # ZSH FIX: 'status' is read-only in Zsh, use 'pkg_status' instead
        local pkg_status="${DIM}○${NC}"
        is_installed "$pkg" && pkg_status="${GREEN}●${NC}"

        local c_cat=""
        case "$cat" in
            "PERF")   c_cat="${PURPLE}PERF${NC}" ;;
            "DISK")   c_cat="${RED}DISK${NC}" ;;
            "SECURE") c_cat="${GREEN}SECU${NC}" ;;
            "NET")    c_cat="${CYAN}NET ${NC}" ;;
            "DEV")    c_cat="${BLUE}DEV ${NC}" ;;
            "MODERN") c_cat="${YELLOW}MOD ${NC}" ;;
            *)        c_cat="${DIM}SYS ${NC}" ;;
        esac

        local line=""
        line=$(printf "%b ${DIM}[%3d]${NC}  %-12b  ${BOLD}%-18s${NC}  ${DIM}%s${NC}" "$pkg_status" "$idx" "$c_cat" "$generic" "$desc")
        menu_items+=("$line|$generic|$pkg")
    done

    # ===== 🖥️ UI LAUNCHER =====
    local selected_raw=""
    selected_raw=$(printf "%s\n" "${menu_items[@]}" | "$FZF_CMD" \
        --ansi --multi --delimiter='\|' --with-nth=1 \
        --height=90% --layout=reverse --border=rounded \
        --prompt="🔍 Search Arsenal > " \
        --header="  [TAB] Select Multiple  |  [ENTER] Process  |  [Q] Exit  | (${PKG_MANAGER})
  ─────────────────────────────────────────────────────────────────────────
  STAT  [IDX]  CATEGORY       PACKAGE          DESCRIPTION")

    [[ $? -ne 0 || -z "$selected_raw" ]] && { echo -e "\n${YELLOW}👋 Operation cancelled.${NC}"; return 0; }

    # ZSH FIX: Extract selections using temp file
    local selected_tools=()
    local actual_packages=()

    local tmpfile="/tmp/ut_selection_$$.txt"
    printf "%s\n" "$selected_raw" > "$tmpfile"

    while IFS= read -r raw_line; do
        [[ -z "$raw_line" ]] && continue
        local t=$(echo "$raw_line" | awk -F'\|' '{print $2}' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        local p=$(echo "$raw_line" | awk -F'\|' '{print $3}' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [[ -n "$t" ]] && selected_tools+=("$t")
        [[ -n "$p" ]] && actual_packages+=("$p")
    done < "$tmpfile"
    rm -f "$tmpfile"

    [[ ${#selected_tools[@]} -eq 0 ]] && { echo -e "${YELLOW}⚠️ Nothing selected${NC}"; return 0; }

    echo -e "${CYAN}📋 Selected ${#selected_tools[@]} tools:${NC}"
    local _i
    for (( _i = 1; _i <= ${#selected_tools[@]}; _i++ )); do
        echo -e "  ${GREEN}●${NC} ${selected_tools[$_i]} (${actual_packages[$_i]})"
    done

    # ===== ⬇️ INSTALL & CONFIG ENGINE =====
    sudo -v || { echo -e "${RED}❌ Sudo required${NC}"; return 1; }

    # Disable job monitor so zsh doesn't print "[N] + terminated ..." when the
    # keepalive process ends. disown alone is not enough in zsh.
    set +m
    (
        while true; do
            sudo -n true 2>/dev/null || exit
            sleep 60
            kill -0 "$$" 2>/dev/null || exit
        done
    ) &>/dev/null &
    local SUDO_KEEPALIVE=$!
    disown $SUDO_KEEPALIVE 2>/dev/null || true
    set -m

    echo -e "${CYAN}🔧 Processing ${#selected_tools[@]} tools on ${DISTRO_ID}...${NC}"

    case "$PKG_MANAGER" in
        "apt") sudo apt update -y &>>"$LOGFILE" ;;
        "dnf"|"yum") sudo $PKG_MANAGER check-update -y &>>"$LOGFILE" || true ;;
        "pacman") sudo pacman -Sy &>>"$LOGFILE" ;;
        "zypper") sudo zypper refresh &>>"$LOGFILE" ;;
        "apk") sudo apk update &>>"$LOGFILE" ;;
        "xbps") sudo xbps-install -Su &>>"$LOGFILE" || true ;;
    esac

    local RC_FILE="$HOME/.bashrc"
    [[ "$SHELL" == */zsh ]] && RC_FILE="$HOME/.zshrc"
    local SHELL_NAME="${SHELL:t}"

    add_config() {
        local marker="$1"
        local content="$2"
        if ! grep -qF "$marker" "$RC_FILE" 2>/dev/null; then
            echo -e "\n# $marker" >> "$RC_FILE"
            echo "$content" >> "$RC_FILE"
        fi
    }

    local failed_pkgs=()
    local installed_pkgs=()

    local _j
    for (( _j = 1; _j <= ${#selected_tools[@]}; _j++ )); do
        local t="${selected_tools[$_j]}"
        local pkg="${actual_packages[$_j]}"

        echo -n -e "${WHITE}📦 $t (${pkg})... ${NC}"

        if is_installed "$pkg"; then
            echo -e "${GREEN}✔ Already installed${NC}"
            installed_pkgs+=("$t")
        else
            if eval "$PKG_INSTALL \"$pkg\"" &>>"$LOGFILE"; then
                echo -e "${GREEN}[INSTALLED]${NC}"
                installed_pkgs+=("$t")
            else
                echo -e "${RED}[FAILED]${NC}"
                failed_pkgs+=("$t ($pkg)")
                continue
            fi
        fi

        case "$t" in
            "docker.io")
                sudo usermod -aG docker "$USER" 2>/dev/null || true
                [[ "$SERVICE_CMD" == "systemctl" ]] && sudo systemctl enable --now docker &>>"$LOGFILE" || true
                ;;
            "tmux")
                [[ ! -f ~/.tmux.conf ]] && echo -e "set -g mouse on\nset -g default-terminal \"screen-256color\"" > ~/.tmux.conf
                ;;
            "git")
                git config --global color.ui auto 2>/dev/null || true
                git config --global core.editor "nano" 2>/dev/null || true
                git config --global init.defaultBranch main 2>/dev/null || true
                ;;
            "neovim")
                mkdir -p ~/.config/nvim
                [[ ! -f ~/.config/nvim/init.vim ]] && echo -e "set number\nset relativenumber\nset mouse=a\nset termguicolors" > ~/.config/nvim/init.vim
                add_config "Neovim Alias" "alias v='nvim'\nalias vim='nvim'"
                ;;
            "zram-tools")
                if [[ "$PKG_MANAGER" == "apt" ]]; then
                    sudo bash -c "echo -e 'PERCENT=60\nALGO=zstd\nPRIORITY=100' > /etc/default/zramswap"
                    sudo systemctl restart zramswap &>>"$LOGFILE" || true
                elif [[ "$PKG_MANAGER" == "pacman" ]]; then
                    sudo pacman -S --noconfirm zram-generator 2>/dev/null || true
                    sudo bash -c "echo -e '[zram0]\nzram-size = ram / 2\ncompression-algorithm = zstd' > /etc/systemd/zram-generator.conf"
                    sudo systemctl daemon-reload &>>"$LOGFILE" || true
                    sudo systemctl start /dev/zram0 &>>"$LOGFILE" || true
                fi
                ;;
            "micro")
                mkdir -p ~/.config/micro
                [[ ! -f ~/.config/micro/settings.json ]] && echo '{"mouse": true, "clipboard": "terminal"}' > ~/.config/micro/settings.json
                ;;
            "ufw")
                command -v ufw &>/dev/null && { sudo ufw allow ssh 2>/dev/null && sudo ufw --force enable &>>"$LOGFILE" || true; }
                ;;
            "htop")
                mkdir -p ~/.config/htop
                [[ ! -f ~/.config/htop/htoprc ]] && echo "highlight_megabytes=1\nshow_program_path=1" > ~/.config/htop/htoprc
                ;;
            "acpi")
                add_config "Battery Status" "alias battery='acpi -V'"
                ;;
            "bat")
                local bat_cmd="bat"
                [[ "$PKG_MANAGER" == "apt" ]] && bat_cmd="batcat"
                add_config "Batcat Alias" "alias cat='$bat_cmd -p'\nalias bat='$bat_cmd'"
                ;;
            "eza")
                add_config "Eza Alias" "alias ls='eza --icons --group-directories-first'"
                ;;
            "zoxide")
                add_config "Zoxide Init" "[ -x \"\$(command -v zoxide)\" ] && eval \"\$(zoxide init $SHELL_NAME)\""
                add_config "Zoxide Alias" "alias cd='z'"
                ;;
            "preload")
                echo -e "${CYAN}🔧 Enabling Preload service...${NC}"
                [[ "$SERVICE_CMD" == "systemctl" ]] && {
                    sudo systemctl enable --now preload &>>"$LOGFILE"
                } || {
                    sudo $SERVICE_CMD preload start &>>"$LOGFILE"
                }
                ;;
            "earlyoom")
                echo -e "${CYAN}🔧 Configuring EarlyOOM...${NC}"
                if [[ "$PKG_MANAGER" == "apt" ]]; then
                    sudo sed -i 's/EARLYOOM_ARGS=.*/EARLYOOM_ARGS="-m 10 -s 5 --prefer '"'^(electron|java|python)'"'"/' /etc/default/earlyoom
                fi
                [[ "$SERVICE_CMD" == "systemctl" ]] && {
                    sudo systemctl enable --now earlyoom &>>"$LOGFILE"
                }
                ;;
            "lm-sensors")
                echo -e "${CYAN}🔍 Detecting Hardware Sensors...${NC}"
                sudo sensors-detect --auto &>>"$LOGFILE"
                [[ "$SERVICE_CMD" == "systemctl" ]] && {
                    sudo systemctl enable --now lm_sensors &>>"$LOGFILE" 2>/dev/null || \
                    sudo systemctl enable --now sensord &>>"$LOGFILE" 2>/dev/null
                }
                add_config "Sensor Alias" "alias temp='sensors'"
                ;;
        esac
    done

    set +m
    kill $SUDO_KEEPALIVE 2>/dev/null || true
    wait $SUDO_KEEPALIVE 2>/dev/null || true
    set -m

    # ===== 🔗 SHELL INTEGRATION =====
    if [[ " ${installed_pkgs[*]} " =~ " fzf " ]]; then
        if [[ "$SHELL_NAME" == "bash" ]] || [[ "$SHELL_NAME" == "zsh" ]]; then
            add_config "FZF Integration" "eval \"\$(fzf --$SHELL_NAME)\""
        fi
    fi

    add_config "HISTORY" "export HISTSIZE=10000\nexport HISTFILESIZE=20000"

    case "$PKG_MANAGER" in
        "apt") sudo apt autoremove -y &>>"$LOGFILE" || true ;;
        "dnf"|"yum") sudo $PKG_MANAGER autoremove -y &>>"$LOGFILE" || true ;;
        "pacman") sudo pacman -Sc --noconfirm &>>"$LOGFILE" || true ;;
    esac

    echo -e "\n${GREEN}✅ Deployment Complete on ${DISTRO_ID}!${NC}"
    echo -e "${GREEN}📦 Installed: ${#installed_pkgs[@]} tools${NC}"

    [[ ${#failed_pkgs[@]} -gt 0 ]] && {
        echo -e "${RED}❌ Failed (${#failed_pkgs[@]}):${NC}"
        printf '  - %s\n' "${failed_pkgs[@]}"
    }

    [[ " ${installed_pkgs[*]} " =~ " docker.io " ]] && echo -e "${YELLOW}⚠️  Log out and back in for Docker group changes${NC}"
    [[ " ${installed_pkgs[*]} " =~ " zoxide " ]] && echo -e "${CYAN}💡 Run 'source $RC_FILE' to enable zoxide${NC}"

    rm -f "$LOGFILE" 2>/dev/null || true
}


# ======================================================
#  📂 all file re name
# ======================================================


rn() {
    local target_dir="${1:-.}"

    if [ ! -d "$target_dir" ]; then
        echo "Error: Directory $target_dir does not exist."
        return 1
    fi

    echo "Cleaning files in: $target_dir"

    # -print0 ব্যবহার করা হয়েছে যাতে ফাইলের নামে স্পেস বা নিউলাইন থাকলেও সমস্যা না হয়
    find "$target_dir" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' filepath; do

        dir=$(dirname "$filepath")
        f=$(basename "$filepath")

        # ১. নাম এবং এক্সটেনশন আলাদা করা (স্মার্ট চেক)
        if [[ "$f" == *.* ]]; then
            filename="${f%.*}"
            extension=".${f##*.}" # ডটসহ এক্সটেনশন
        else
            filename="$f"
            extension="" # এক্সটেনশন নেই
        fi

        # ২. নাম ক্লিন করা
        clean_name=$(echo "$filename" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9_-]//g')
        clean_ext=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

        new_name="${clean_name}${clean_ext}"

        # ৩. রিনেম কন্ডিশন
        if [ "$f" != "$new_name" ]; then
            if [ -e "$dir/$new_name" ]; then
                echo "Skipped: '$new_name' already exists."
            else
                mv "$dir/$f" "$dir/$new_name"
                echo "Renamed: '$f' -> '$new_name'"
            fi
        fi
    done
    echo "Done!"
}



# ======================================================
#  📂 package genarator
# ======================================================

# Smart Universal Package Converter & Manager
pg() {
    local file="$1"
    local install_flag="$2"
    local os_type=""
    local pkg_manager=""
    local target_ext=""

    # ১. OS এবং প্যাকেজ ম্যানেজার ডিটেক্ট করা
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|deepin|debian|kali|linuxmint|pop)
                os_type="debian"
                pkg_manager="apt"
                target_ext="deb"
                ;;
            fedora|rhel|centos|amzn)
                os_type="redhat"
                pkg_manager="dnf"
                target_ext="rpm"
                ;;
            arch|manjaro)
                os_type="arch"
                pkg_manager="pacman"
                target_ext="tgz" # Alien Arch এর জন্য tgz ব্যবহার করে
                ;;
            *)
                echo "Sorry Your OS ($PRETTY_NAME) is not supported by this script."
                return 1
                ;;
        esac
    fi

    # ২. ইনপুট চেক
    if [[ -z "$file" ]]; then
        echo "ব্যবহার: superconv [ফাইল_নাম] [-i]"
        echo "OS ডিটেক্ট করা হয়েছে: $PRETTY_NAME"
        return 1
    fi

    # ৩. Alien টুলটি আছে কিনা চেক ও ইনস্টল করা
    if ! command -v alien &> /dev/null; then
        echo "Alien not installed $pkg_manager Package Used To install..."
        if [[ "$pkg_manager" == "apt" ]]; then
            sudo apt update && sudo apt install alien -y
        elif [[ "$pkg_manager" == "dnf" ]]; then
            sudo dnf install alien -y
        elif [[ "$pkg_manager" == "pacman" ]]; then
            sudo pacman -S alien --noconfirm
        fi
    fi

    # ৪. কনভার্ট করা (OS অনুযায়ী target ফরম্যাট সেট করা)
    if [[ -f "$file" ]]; then
        echo "Converter $target_ext format..."

        case "$os_type" in
            "debian") sudo alien --to-deb --scripts "$file" ;;
            "redhat") sudo alien --to-rpm --scripts "$file" ;;
            "arch")   sudo alien --to-tgz --scripts "$file" ;;
        esac

        if [[ $? -eq 0 ]]; then
            echo "--- file Convert successfully ! ---"

            # ৫. কন্ডিশনাল ইনস্টলেশন
            if [[ "$install_flag" == "-i" ]]; then
                local new_pkg=$(ls -t *.$target_ext | head -1)
                echo "This Package intsalling: $new_pkg"

                if [[ "$pkg_manager" == "apt" ]]; then
                    sudo dpkg -i "$new_pkg" && sudo apt install -f
                elif [[ "$pkg_manager" == "dnf" ]]; then
                    sudo dnf install ./"$new_pkg" -y
                elif [[ "$pkg_manager" == "pacman" ]]; then
                    sudo pacman -U "$new_pkg" --noconfirm
                fi
            fi
        else
            echo "convarsion Failed !"
        fi
    else
        echo "file is missing: $file"
    fi
}





# ======================================================
#  📂 ALIASES: Navigation & System
# ======================================================

# --- Basic Navigation ---
alias c='clear'
alias cls='clear'
alias rd='cd /'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# alias drive='cd /media/Rihad/085df205-a554-40c8-b0b1-59a1ad469a94'

drive() {
    local drive1_uuid="469a94"
    local drive2_uuid="b2c89f" # Apnar 2nd drive er UUID match kore niben

    local target_path=""

    if [[ "$1" == "1" || -z "$1" ]]; then
        target_path=$(print /media/*/*${drive1_uuid}(-N))
    elif [[ "$1" == "2" ]]; then
        target_path=$(print /media/*/*${drive2_uuid}(-N))
    else
        echo "❌ Invalid option! Use: 'drive' or 'drive 1', 'drive 2'"
        return 1
    fi

    if [ -d "$target_path" ]; then
        cd "$target_path"
        echo "📂 Switched to: $target_path"
    else
        echo "❌ Error: Driveটি খুঁজে পাওয়া যায়নি!"
    fi
}


# --- Quick Folder Jumps (Change paths as needed) ---
alias dev='cd ~/Developer'
alias doc='cd ~/Documents'
alias dow='cd ~/Downloads'
alias des='cd ~/Desktop'
alias pic='cd ~/Pictures'
alias vid='cd ~/Videos'
alias mus='cd ~/Music'

# --- Project Shortcuts ---
alias ar='cd ~/Developer/archive'
alias ba='cd ~/Developer/backend'
alias de='cd ~/Developer/dev'
alias fig='cd ~/Developer/Figma'
alias fr='cd ~/Developer/frontend'
alias fu='cd ~/Developer/fullstack'


# --- System Maintenance ---
alias update='sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt-get install -f && flatpak update -y'
alias clean='sudo apt-get autoremove --purge -y && sudo apt-get autoclean && sudo apt-get clean -y && flatpak uninstall --unused -y && flatpak repair'
alias zshrc='code ~/.zshrc'
alias to='code .'
alias rel='source ~/.zshrc && echo "✅ .zshrc reloaded successfully!"'

# --- Network & Server ---
alias serve='python3 -m http.server'
alias ports='ss -tulpn'
alias myip='ip a | grep inet'



# ======================================================
#  🛠️  FUNCTION TOOLS (Better than Aliases)
# ======================================================


# Create directory and enter it immediately
# Usage: mkd new_folder
mkd() {
    mkdir -p "$1" && cd "$1" && echo "✅ Created & Entered: $1"
}

# Force remove directory
# Usage: rmd folder_name
rmd() {
    rm -rf "$1" && echo "✅ Removed directory: $1"
}

# Remove file with confirmation
# Usage: rmf file.txt
rmf() {
    rm -i "$1" && echo "✅ Removed file: $1"
}

# Auto 'ls' after cd (Lists files automatically when you switch folders)
# cd() {
#     builtin cd "$@" && ls --color=auto -F
# }


# ======================================================
#  📦 DEV STACK ALIASES (NPM, BUN, GIT)
# ======================================================

# --- NPM Shortcuts ---
alias ni='npm install'
alias nid='npm install -D'
alias nr='npm run'
alias nrd='npm run dev'
alias nrb='npm run build'
alias nrs='npm run start'

# --- Bun Shortcuts ---
alias bi='bun install'
alias br='bun run'
alias brd='bun run dev'
alias brb='bun run build'
alias brs='bun run start'
alias html='bun run index.html'
alias w='bun --watch'
alias h='bun --hot'

# --- Git Shortcuts ---
alias gi='git init'
alias gs='git status -sb'
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gd='git diff'
alias gco='git checkout'
alias gcm='git commit -m'
alias gpl='git pull'
alias gps='git push'
alias gb='git branch'
alias gcb='git checkout -b'
alias ga='git add .'
alias gr='git restore'
alias grh='git reset HEAD~1'
alias gc='git clone'
alias gst='git stash'
alias gsta='git stash apply'
alias gpop='git stash pop'
# Fetch and prune deleted branches
alias gfp='git fetch --prune'


alias vlc="flatpak run org.videolan.VLC"
alias brave="flatpak run com.brave.Browser"
alias youtube="brave --app=https://www.youtube.com"

# Handle unknown commands politely
command_not_found_handle() {
  echo "❌ Command not found: $1"
  echo "🔍 Try searching: apt search $1 | npm i -g $1"
}


alias br='cd ~/Downloads/Brave'
alias ch='cd ~/Downloads/Chrome'
alias gp='cd ~/Downloads/Google\ Photos'
alias pa='cd ~/Downloads/Packet'
alias ss='cd ~/Downloads/Screenshot'
alias vi='cd ~/Downloads/Video'


# Zsh-এর জন্য autocd active করার নিয়ম
setopt autocd

# Remove any Flatpak app paths from LD_LIBRARY_PATH
if [[ -n "$LD_LIBRARY_PATH" ]] && [[ "$LD_LIBRARY_PATH" == *"/var/lib/flatpak/app/"* ]]; then
    # Filter out Flatpak app paths, keep system paths
    new_path=$(echo "$LD_LIBRARY_PATH" | tr ':' '\n' | grep -v "/var/lib/flatpak/app/" | grep -v "$HOME/.local/share/flatpak/app/" | paste -sd ':' -)
    if [[ -n "$new_path" ]]; then
        export LD_LIBRARY_PATH="$new_path"
    else
        unset LD_LIBRARY_PATH
    fi
fi

# Enable autocomplete
autoload -Uz compinit
compinit

# Autocomplete and Syntax Highlighting
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# Command history settings
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Share history between multiple terminals
setopt share_history
setopt append_history
setopt appendhistory
setopt sharehistory

# 1. Auto-LS and FZF Summary Preview when changing directory
# Clear out traditional chpwd to avoid any duplicates from old code
if functions chpwd >/dev/null; then unfunction chpwd; fi

# Accurate and Modern Auto-LS Function
accurate_auto_ls() {
    emulate -L zsh

    # Zsh array parsing flags:
    # (N) empty dir handle, (.) shudhu regular files, (I) ignore traditional exclusions
    local -a total_files=( *(-.N) )
    local -a hidden_files=( .*(.-N) )

    # Safely removing '.' and '..' manually from hidden array
    hidden_files=(${hidden_files:#.(|.)})

    local file_count=${#total_files}
    local hidden_count=${#hidden_files}

    # Clean UI rendering
    echo -e "\n\e[1;35m📂 Directory: ${PWD:t}\e[0m (\e[32m$file_count files\e[0m | \e[33m$hidden_count hidden\e[0m)"
    echo -e "\e[2m───────────────────────────────────────\e[0m"

    # Display using explicit native columns
    ls -FA --color=auto
}

# Standard Zsh hook array registration (Safest approach to avoid duplicates)
typeset -gU chpwd_functions
chpwd_functions=(accurate_auto_ls)

# 2. Advanced FZF Quick CD Function (Optional but highly recommended)
# Terminal-e shudhu 'cf' likhle fzf open hobe pipeline preview shoho

cf() {
    local dir
    local search_cmd

    # 1. Faster search utilizing fd (respects .gitignore natively)
    if command -v fd &> /dev/null; then
        search_cmd="fd --type d --hidden --exclude .git --exclude node_modules . ${1:-.}"
    else
        search_cmd="find ${1:-.} -path '*/.*' -prune -o -type d -print 2>/dev/null"
    fi

    # 2. Fully Immersive Multi-Action Workflow (Fixed Pipeline bindings)
    dir=$(eval "$search_cmd" | fzf \
        --height 90% \
        --layout=reverse \
        --border=rounded \
        --prompt="⚡ Dev Walk: " \
        --pointer="❯" \
        --marker="✔" \
        --header="[ENTER] Cd | [CTRL-O] VS Code | [CTRL-Y] Copy Path | [CTRL-H] Parent Dir" \
        --header-first \
        --bind "ctrl-y:execute-silent(echo -n {} | xclip -selection clipboard || echo -n {} | pbcopy)+change-prompt(📋 Copied! > )" \
        --bind "ctrl-o:execute(code {} || cursor {} || nvim {})+abort" \
        --bind "ctrl-h:reload(fd --type d --hidden --exclude .git --exclude node_modules . {1:h} || find {1:h} -type d)+change-prompt(⚡ Parent: )" \
        --preview '
            # Folder base details
            echo -e "\e[1;34m📁 Contents of: {} \e[0m"
            echo -e "\e[2m──────────────────────────────────────────\e[0m"
            ls -FA --color=always {} | head -20
            echo -e "\e[2m──────────────────────────────────────────\e[0m"

            # Smart Git Tracking Injection inside Preview
            if [ -d "{}/.git" ]; then
                echo -e "\e[1;32m🌿 Git Repo Detect:\e[0m Branch -> \e[1;36m$(git -C {} branch --show-current 2>/dev/null)\e[0m"
                echo -e "\e[1;33m📝 Uncommitted Changes:\e[0m"
                git -C {} status -s 2>/dev/null | head -10 || echo "Clean"
                echo -e "\e[2m──────────────────────────────────────────\e[0m"
            fi

            echo -e "\e[1;33m📊 Total Folder Size:\e[0m $(du -sh {} 2>/dev/null | cut -f1)"
        ' \
        --preview-window=right:50%:wrap)

    if [ -n "$dir" ]; then
        cd "$dir"
    fi
}


# --- Auto Completion ---
autoload -Uz compinit
compinit

# --- Deepin System Colors ---
if [[ ("$TERM" = *256color || "$TERM" = screen* || "$TERM" = xterm* ) && -f /etc/lscolor-256color ]]; then
    eval $(dircolors -b /etc/lscolor-256color)
else
    eval $(dircolors)
fi
alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -A'

# --- Load Bash Aliases if exists ---
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi


# ====================================================================
#              🐳 THE ULTIMATE DOCKER SWISS ARMY KNIFE (ZSH) 🐳
# ====================================================================

# --------------------------------------------------------------------
# ১. স্ট্যাটাস, লিস্ট এবং সাইজ মনিটরিং (Status & Monitoring)
# --------------------------------------------------------------------
alias dps="docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias dpsa="docker ps -a"
alias di="docker images"
alias dvl="docker volume ls"
alias dnl="docker network ls"
alias dsize="docker system df"
alias dtop="docker stats --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}'"

# --------------------------------------------------------------------
# ১বি. SUDO ডকার শর্টকাট (Sudo Docker Shortcuts)
# --------------------------------------------------------------------
alias sdps="sudo docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias sdpsa="sudo docker ps -a"
alias sdi="sudo docker images"
alias sdvl="sudo docker volume ls"
alias sdnl="sudo docker network ls"
alias sdsize="sudo docker system df"
alias sdtop="sudo docker stats --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}'"

# --------------------------------------------------------------------
# ১গ. ডকার সার্ভিস কন্ট্রোল (Docker Service Control via systemctl)
# --------------------------------------------------------------------
# ডকার সার্ভিস চালু করতে
alias dstart="sudo systemctl start docker"
# ডকার সার্ভিস বন্ধ করতে
alias doff="sudo systemctl stop docker"
# ডকার সার্ভিস চালু নাকি বন্ধ তা দেখতে
alias dstatus="sudo systemctl status docker"
# পিসি অন হলে ডকার অটো-স্টার্ট চালু করতে (docker + docker.socket উভয়)
alias denable="sudo systemctl enable docker && sudo systemctl enable docker.socket"
# পিসি অন হলে ডকার অটো-স্টার্ট বন্ধ করতে (docker + docker.socket উভয়)
alias ddisable="sudo systemctl disable docker && sudo systemctl disable docker.socket"

# --------------------------------------------------------------------
# ২. কন্টেইনার লাইফসাইকেল (Container Lifecycle & Control)
# --------------------------------------------------------------------
alias dstop="docker stop"
alias drm="docker rm"
alias drmi="docker rmi"
alias drestart="docker restart"
alias dkill="docker rm -f"
alias dstopall='docker stop $(docker ps -q)'
alias drmall='docker rm $(docker ps -a -q)'

# --------------------------------------------------------------------
# ৩. ডিবাগিং, লগ এবং ইমেজ বিল্ড (Debugging & Building)
# --------------------------------------------------------------------
alias dsh="docker exec -it"
alias dlogs="docker logs -f"
alias dbuild="docker build -t"
alias dbuild-nocache="docker build --no-cache -t"
alias dhist="docker history"
alias dports="docker port"

# --------------------------------------------------------------------
# ৪. ডকার কম্পোজ শর্টকাট (Docker Compose)
# --------------------------------------------------------------------
alias dcup="docker compose up -d"
alias dcdn="docker compose down"
alias dclogs="docker compose logs -f"
alias dcupb="docker compose up -d --build"

# --------------------------------------------------------------------
# ৫. কুইক টেস্ট স্যান্ডবক্স (Temporary Test Containers)
# --------------------------------------------------------------------
alias dtest-ubuntu="docker run --rm -it ubuntu:latest bash"
alias dtest-node="docker run --rm -it node:alpine sh"
alias dtest-alpine="docker run --rm -it alpine:latest sh"

# --------------------------------------------------------------------
# ৬. স্মার্ট এবং অ্যাডভান্সড ফাংশন (Advanced Functions)
# --------------------------------------------------------------------

dfind() {
    echo -e "\e[1;34m--> Running Containers:\e[0m"
    docker ps | grep -i "$1"
    echo -e "\n\e[1;32m--> Downloaded Images:\e[0m"
    docker images | grep -i "$1"
}

droot() {
    docker exec -it -u root "$1" bash 2>/dev/null || docker exec -it -u root "$1" sh
}

dip() {
    docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$1"
}

dwatch() {
    if [ -z "$1" ]; then echo "Usage: dwatch <container-name>"; return 1; fi
    echo -e "\e[1;35mWatching file changes in '$1' (Press Ctrl+C to stop)...\e[0m"
    watch -n 1 "docker diff $1"
}

dnetstat() {
    if [ -z "$1" ]; then echo "Usage: dnetstat <container-name>"; return 1; fi
    echo -e "\e[1;36mActive connections inside '$1':\e[0m"
    docker exec -it "$1" netstat -tulan 2>/dev/null || docker exec -it "$1" ss -tulan 2>/dev/null || echo "Error: Neither netstat nor ss is installed in this container."
}

dtop-proc() {
    if [ -z "$1" ]; then echo "Usage: dtop-proc <container-name>"; return 1; fi
    docker top "$1" aux
}

dbackup() {
    docker run --rm -v "$1":/volume -v "$(pwd)":/backup alpine tar cvf /backup/"$2" -C /volume .
}

dkill-force() {
    echo -e "\e[1;31m⚠️  WARNING: You are about to stop and remove ALL running containers!\e[0m"
    read "confirm?Are you sure? (y/N): "
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        docker stop $(docker ps -q) 2>/dev/null
        docker rm $(docker ps -a -q) 2>/dev/null
        echo -e "\e[1;32mDone. All containers cleared.\e[0m"
    else
        echo "Operation cancelled."
    fi
}

dclean() {
    echo -e "\e[1;31m🧹 Performing deep clean of all unused Docker resources...\e[0m"
    docker system prune -a --volumes -f
    echo -e "\e[1;32m✨ System optimization complete!\e[0m"
}

# --------------------------------------------------------------------
# ৭. ZSH ইন্টেলিজেন্ট ট্যাব কমপ্লিশন (Zsh Smart Tab Completion)
# --------------------------------------------------------------------

# Zsh-এর ডিফল্ট কমপ্লিশন সিস্টেম লোড করা (যদি অলরেডি লোড করা না থাকে)
autoload -Uz compinit && compinit -i

# কন্টেইনারের নামের জন্য কমপ্লিশন ফাংশন
_zsh_docker_containers() {
    local -a containers
    containers=(${(f)"$(docker ps -a --format '{{.Names}}')"})
    _describe 'containers' containers
}

# ইমেজের নামের জন্য কমপ্লিশন ফাংশন
_zsh_docker_images() {
    local -a images
    images=(${(f)"$(docker images --format '{{.Repository}}' | grep -v '<none>')"})
    _describe 'images' images
}

# নির্দিষ্ট শর্টকাট কমান্ডগুলোর সাথে কমপ্লিশন লিঙ্ক করা
compdef _zsh_docker_containers dsh dlogs dstop dkill drestart dports dwatch dnetstat dtop-proc
compdef _zsh_docker_images drmi dhist

# --------------------------------------------------------------------
# ৮. স্টার্টআপ নোটিফায়ার (Startup Notifier)
# --------------------------------------------------------------------
if command -v docker &> /dev/null && systemctl is-active --quiet docker 2>/dev/null; then
    running_count=$(docker ps -q | wc -l)
    if [ "$running_count" -gt 0 ]; then
        echo -e "\e[1;36m🐳 Docker is active. Running containers: $running_count\e[0m"
    fi
fi



# =====================================================
# Advance C/C++ boilerplate generator
# =====================================================
makecpp() {
    if [[ -z "$1" ]]; then
        echo "❌ Error: Please provide a project name! (e.g., makecpp my_project)"
        return 1
    fi

    local lang_choice="$2"
    if [[ -z "$lang_choice" ]]; then
        if (( $+commands[fzf] )); then
            echo "🤔 Which language project do you want to create?"
            lang_choice=$(printf "cpp\nc\n" | fzf --prompt="Select Language > " --height=10 --layout=reverse)
            [[ -z "$lang_choice" ]] && lang_choice="cpp"
        else
            printf "🤔 Which language project do you want to create? (c/cpp) [default: cpp]: "
            read lang_choice
        fi
    fi

    local type="cpp"
    local compiler="g++"
    local file_ext="cpp"
    local flags="-std=c++17 -Wall -Wextra -O2"

    if [[ "$lang_choice" == "c" || "$lang_choice" == "C" ]]; then
        type="c"
        compiler="gcc"
        file_ext="c"
        flags="-Wall -Wextra -O2"
    fi

    echo "🚀 Creating Advance $type project: $1..."
    mkdir -p "$1" && cd "$1" || return

    # 1. Generate general boilerplate code
    if [[ "$type" == "c" ]]; then
        cat <<EOF > main.c
#include <stdio.h>

int main() {
    printf("Hello, World! Welcome to C project: %s\n", "$1");
    return 0;
}
EOF
    else
        cat <<EOF > main.cpp
#include <iostream>

int main() {
    std::cout << "Hello, World! Welcome to C++ project: " << "$1" << std::endl;
    return 0;
}
EOF
    fi

    # 2. Create a smart Makefile
    cat <<EOF > Makefile
CC = $compiler
CFLAGS = $flags
TARGET = main

all: \$(TARGET)

\$(TARGET): main.$file_ext
	\$(CC) \$(CFLAGS) main.$file_ext -o \$(TARGET)

run: \$(TARGET)
	./\$(TARGET)

clean:
	rm -f \$(TARGET)
EOF

    # 3. Auto-initialize Git and create .gitignore
    if (( $+commands[git] )); then
        git init -q
        echo -e "main\n*.o\n*.out\n.vscode/" > .gitignore
        echo "✅ Git repository initialized with .gitignore"
    fi

    echo "🎉 Project setup complete!"
    echo "📂 Current directory: $(pwd)"

    # 4. Open in VS Code automatically if available
    if (( $+commands[code] )); then
        echo "💻 Opening in VS Code..."
        code .
    fi
}

# =====================================================
# End of .bashrc
# =====================================================
