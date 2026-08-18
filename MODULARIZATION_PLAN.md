# fancybash Modularization Plan

fancybash এর বর্তমান `config.sh` একটি **6351 লাইনের monolithic ফাইল**।
এটিকে logical module-এ ভেঙে দিলে contribute করা, maintain করা এবং নতুন feature যোগ করা অনেক সহজ হবে।

---

## User Review Required

> [!IMPORTANT]
> এই প্ল্যানটি `config.sh` কে ভেঙে `modules/` ফোল্ডারে আলাদা ফাইলে রাখবে।
> মূল `config.sh` ফাইলটি **entry point** হিসেবে থাকবে এবং সব module `source` করবে।
> বিদ্যমান install flow (**install.sh**, **install.zsh** ইত্যাদি) একই থাকবে।

> [!WARNING]
> config.zsh, config.fish, config.ps1 — এই ফাইলগুলো আলাদাভাবে modularize করা হবে না এই পর্যায়ে।
> শুধু `config.sh` (bash) এই প্রথম ধাপে modularize করা হবে।

---

## Open Questions

> [!IMPORTANT]
> **Q1:** config.sh এর modular version কি backward-compatible থাকবে?
> অর্থাৎ, পুরনো users যারা directly `source ~/.bashrc` করে তারা কোনো পরিবর্তন ছাড়াই কাজ করতে পারবে?
> → **হ্যাঁ**, `config.sh` entry point হিসেবে থাকবে, শুধু ভেতরে `source` calls যোগ হবে।

> [!IMPORTANT]
> **Q2:** Modules কি optional হবে? (যেমন — Docker না থাকলে docker module skip হবে?)
> → **হ্যাঁ**, প্রতিটি module এর শুরুতে `command -v` check থাকবে।

---

## Proposed Changes

### Current Structure (সমস্যা)

```
fancybash/
├── config.sh          ← 6351 লাইন! সব কিছু এখানে
├── config.zsh         ← 6623 লাইন
├── config.fish        ← বড় ফাইল
├── config.ps1         ← বড় ফাইল
└── install.sh
```

### Proposed Structure (সমাধান)

```
fancybash/
├── config.sh              ← Entry point (শুধু source calls)
├── modules/               ← [NEW] সব bash module
│   ├── 00-colors.sh       ← Rainbow colors, emoji setup
│   ├── 01-helpers.sh      ← _fb_ensure_dep, _fb_sed_i, parse_git_branch
│   ├── 02-prompt.sh       ← PS1, sys_info, battery, cpu_temp, git_branch
│   ├── 03-project-setup.sh← ii, next, vite, tailwind setup functions
│   ├── 04-git.sh          ← git aliases, git wip/push, gbranch
│   ├── 05-navigation.sh   ← cd aliases, mkd, rmd, drive
│   ├── 06-dev-aliases.sh  ← npm, bun, pnpm, yarn shortcuts
│   ├── 07-system.sh       ← ut (optimizer), rt (runtime install), rn, pg
│   ├── 08-docker.sh       ← Docker aliases & functions
│   ├── 09-fzf-tools.sh    ← cf (fzf cd), accurate_auto_ls, fzf utilities
│   ├── 10-todo-notes.sh   ← TODO & Notes utilities
│   ├── 11-media.sh        ← ffmpeg suite (ffmedia, ffstudio)
│   ├── 12-cpp.sh          ← C/C++ boilerplate generator (makecpp)
│   └── 13-extras.sh       ← misc utilities
└── install.sh             ← একই থাকবে (no change)
```

---

### [MODIFY] config.sh — Entry Point হবে

```bash
# config.sh — fancybash Entry Point
# সমস্ত module এখানে source করা হয়

FANCYBASH_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

_fb_load_module() {
    local mod="$1"
    if [[ -f "$FANCYBASH_DIR/modules/$mod" ]]; then
        source "$FANCYBASH_DIR/modules/$mod"
    else
        echo "⚠️  fancybash: module '$mod' not found" >&2
    fi
}

_fb_load_module "00-colors.sh"
_fb_load_module "01-helpers.sh"
_fb_load_module "02-prompt.sh"
_fb_load_module "03-project-setup.sh"
_fb_load_module "04-git.sh"
_fb_load_module "05-navigation.sh"
_fb_load_module "06-dev-aliases.sh"
_fb_load_module "07-system.sh"
_fb_load_module "08-docker.sh"
_fb_load_module "09-fzf-tools.sh"
_fb_load_module "10-todo-notes.sh"
_fb_load_module "11-media.sh"
_fb_load_module "12-cpp.sh"
_fb_load_module "13-extras.sh"
```

---

### Section Mapping (কোন লাইন কোন module-এ যাবে)

| Module | Lines (config.sh) | বিষয় |
|--------|-------------------|-------|
| `00-colors.sh` | 1–35 | Rainbow colors, emoji |
| `01-helpers.sh` | 37–90 | `_fb_ensure_dep`, `_fb_sed_i` |
| `02-prompt.sh` | 91–246 | `parse_git_branch`, `sys_info`, `PS1` |
| `03-project-setup.sh` | 248–611 | `ii`, `next`, `vite`, tailwind |
| `04-git.sh` | 766–862 + 4163–4223 | Git aliases + `gbranch` |
| `05-navigation.sh` | 3930–4110 | cd aliases, `mkd`, `rmd` |
| `06-dev-aliases.sh` | 4141–4223 | npm, bun, pnpm shortcuts |
| `07-system.sh` | 3241–3787 | `ut`, `rt`, `rn`, `pg` |
| `08-docker.sh` | 4433–5145 | Docker aliases/functions |
| `09-fzf-tools.sh` | 4224–4432 | `cf`, `accurate_auto_ls` |
| `10-todo-notes.sh` | 5311–5810 | TODO, notes utilities |
| `11-media.sh` | 5811–6347 | ffmpeg suite |
| `12-cpp.sh` | (C++ section) | `makecpp` |
| `13-extras.sh` | বাকি সব | misc |

---

### Install Script Update

`install.sh` এ শুধু একটা ছোট পরিবর্তন — পুরো `config.sh` এর বদলে
modules ফোল্ডারসহ clone/download করতে হবে।

**curl-based install** এর ক্ষেত্রে:
- হয় পুরো repo clone করতে হবে (git clone)
- অথবা একটা single `config.sh` রাখা যাবে যেখানে সব embed থাকবে (release build)

> [!TIP]
> **দুটি ডিস্ট্রিবিউশন মোড** রাখা যায়:
> 1. **Dev Mode**: `git clone` করলে modular version পাবে
> 2. **Release Mode**: `curl | bash` করলে single bundled `config.sh` পাবে (CI দিয়ে auto-build)

---

## Verification Plan

### Automated Tests
```bash
# সব module load হয় কিনা test
bash -c 'source config.sh && echo "✅ All modules loaded"'

# কোনো function missing কিনা check
bash -c 'source config.sh && declare -F | wc -l'
```

### Manual Verification
- Terminal reload করে দেখা সব alias কাজ করে কিনা
- `ii`, `next`, `cf`, `ut`, `makecpp` — প্রতিটা function test করা
- Git aliases test করা

---

## কেন এই approach?

| সমস্যা (আগে) | সমাধান (পরে) |
|---|---|
| 6351 লাইনের একটি ফাইল | 14টি ছোট, focused ফাইল |
| একটি function খুঁজতে scroll করতে হয় | module নাম দেখেই বোঝা যাবে কোথায় আছে |
| নতুন feature যোগ করতে ভয় | শুধু নতুন module file যোগ করলেই হবে |
| PR review কঠিন | ছোট ফাইলে diff পরিষ্কার দেখা যাবে |
| সব feature সবার লাগে না | optional module skip করা যাবে |
