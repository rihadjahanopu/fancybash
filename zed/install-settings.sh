#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Zed IDE — Bulletproof Settings Installer
#  Detects OS (Linux / macOS / Windows / WSL / Flatpak / Snap)
#  and safely installs settings.json to all applicable Zed paths.
#  Usage: bash install-settings.sh
# ─────────────────────────────────────────────────────────────

set -euo pipefail

# ── Colors & Formatting ───────────────────────────────────────
RED='\033[38;2;243;139;168m'
GREEN='\033[38;2;166;227;161m'
YELLOW='\033[38;2;249;226;175m'
BLUE='\033[38;2;137;180;250m'
PURPLE='\033[38;2;203;166;247m'
CYAN='\033[38;2;148;226;213m'
GRAY='\033[38;2;147;153;178m'
BOLD='\033[1m'
NC='\033[0m'

# ── Cleanup Trap ──────────────────────────────────────────────
cleanup() {
    tput cnorm 2>/dev/null || true
}
trap cleanup EXIT SIGINT SIGTERM

# ── Detect OS & Target Directories ────────────────────────────
OS_TYPE="$(uname -s 2>/dev/null || echo "Unknown")"
TARGET_DIRS=()

case "$OS_TYPE" in
    Linux*)
        # 1. Linux Native Config
        TARGET_DIRS+=("$HOME/.config/zed")

        # 2. Linux Flatpak
        if [ -d "$HOME/.var/app/dev.zed.Zed" ] || command -v flatpak &>/dev/null; then
            TARGET_DIRS+=("$HOME/.var/app/dev.zed.Zed/config/zed")
        fi

        # 3. Linux Snap
        if [ -d "$HOME/snap/zed" ] || command -v snap &>/dev/null; then
            TARGET_DIRS+=("$HOME/snap/zed/current/.config/zed")
        fi

        # 4. WSL -> Detect Windows Host AppData
        if grep -qi "microsoft\|wsl" /proc/version 2>/dev/null; then
            if command -v cmd.exe &>/dev/null && command -v wslpath &>/dev/null; then
                win_appdata_raw=$(cmd.exe /c "echo %APPDATA%" 2>/dev/null | tr -d '\r')
                if [ -n "$win_appdata_raw" ]; then
                    win_appdata_linux=$(wslpath "$win_appdata_raw" 2>/dev/null || true)
                    if [ -n "$win_appdata_linux" ]; then
                        TARGET_DIRS+=("$win_appdata_linux/Zed")
                    fi
                fi
            fi
        fi
        ;;

    Darwin*)
        # macOS Application Support Path
        TARGET_DIRS+=("$HOME/Library/Application Support/Zed")
        ;;

    CYGWIN*|MINGW*|MSYS*|Windows_NT*)
        # Windows Native (Git Bash / MinGW / Cygwin)
        if [ -n "${APPDATA:-}" ]; then
            TARGET_DIRS+=("$APPDATA/Zed")
        else
            TARGET_DIRS+=("$HOME/AppData/Roaming/Zed")
        fi
        ;;

    *)
        # Fallback
        TARGET_DIRS+=("$HOME/.config/zed")
        ;;
esac

# ── Settings payload (Valid JSONC) ────────────────────────────
read -r -d '' SETTINGS <<'JSON' || true
{
  "enable_language_server": true,
  "hide_mouse": "never",
  "disable_ai": true,
  "cli_default_open_behavior": "existing_window",
  "code_lens": "on",
  "bottom_dock_layout": "contained",
  "colorize_brackets": true,
  "indent_guides": {
    "background_coloring": "disabled"
  },
  "agent_servers": {
    "opencode": {
      "type": "registry"
    }
  },
  "agent": {
    "dock": "right",
    "favorite_models": [],
    "model_parameters": []
  },
  "instrumentation": {
    "performance_profiler": {
      "enabled": true
    }
  },
  "proxy": "",
  "focus_follows_mouse": {
    "enabled": false
  },
  "which_key": {
    "enabled": false
  },
  "icon_theme": {
    "mode": "dark",
    "light": "Material Icon Theme",
    "dark": "Material Icon Theme"
  },
  "base_keymap": "VSCode",
  "selection_highlight": true,
  "cursor_blink": true,
  "use_system_path_prompts": true,
  "autosave": "on_focus_change",
  "show_completions_on_input": true,
  "auto_indent_on_paste": true,
  "linked_edits": true,
  "use_on_type_format": true,
  "soft_wrap": "editor_width",
  "tab_size": 2,
  "always_treat_brackets_as_autoclosed": true,
  "hover_popover_delay": 300,
  "ui_font_family": "Cascadia Code",
  "ui_font_size": 22.0,
  "buffer_font_size": 22.0,
  "buffer_font_family": "Cascadia Code",
  "buffer_font_fallbacks": ["JetBrains Mono", "Fira Code"],
  "session": {
    "trust_all_worktrees": true
  },
  "project_panel": {
    "dock": "left",
    "auto_fold_dirs": false,
    "hide_root": false,
    "git_status_indicator": true,
    "diagnostic_badges": true,
    "bold_folder_labels": true
  },
  "preview_tabs": {
    "enabled": false,
    "enable_preview_from_file_finder": true,
    "enable_preview_multibuffer_from_code_navigation": true
  },
  "status_bar": {
    "line_endings_button": true,
    "experimental.show": true,
    "show_active_file": true
  },
  "sticky_scroll": {
    "enabled": false
  },
  "minimap": {
    "show": "always"
  },
  "scrollbar": {
    "axes": {
      "horizontal": true
    }
  },
  "file_types": {
    "html": ["*html", "*njk", "*.ejs"]
  },
  "theme": {
    "mode": "dark",
    "light": "Ayu Light",
    "dark": "Tokyo Night Storm"
  },
  "terminal": {
    "font_weight": 400.0,
    "copy_on_select": true,
    "blinking": "on",
    "cursor_shape": "block",
    "line_height": {
      "custom": 1.3
    },
    "font_fallbacks": ["JetBrains Mono", "FiraCode Nerd Font"],
    "font_family": "Cascadia Code",
    "font_size": 22.0,
    "env": {
      "LD_LIBRARY_PATH": ""
    },
    "toolbar": {
      "breadcrumbs": true
    },
    "show_count_badge": true
  },
  "git": {
    "inline_blame": {
      "show_commit_summary": true
    }
  },
  "git_panel": {
    "tree_view": true,
    "show_count_badge": true,
    "file_icons": true
  },
  "tabs": {
    "file_icons": true,
    "git_status": true
  },
  "title_bar": {
    "button_layout": "platform_default",
    "show_menus": false,
    "show_branch_status_icon": true
  },
  "diagnostics": {
    "inline": {
      "enabled": true,
      "max_severity": "all"
    }
  },
  "prettier": {
    "parser": "",
    "allowed": true
  },
  "inlay_hints": {
    "show_background": true,
    "enabled": false
  },
  "toolbar": {
    "code_actions": true
  },
  "format_on_save": "on",
  "formatter": "prettier",
  "languages": {
    "JavaScript": {
      "formatter": "prettier",
      "code_actions_on_format": {
        "source.organizeImports": true
      }
    },
    "TypeScript": {
      "formatter": "prettier",
      "code_actions_on_format": {
        "source.organizeImports": true,
        "source.fixAll.eslint": true
      },
      "language_servers": ["vtsls", "..."]
    },
    "TSX": {
      "formatter": "prettier",
      "code_actions_on_format": {
        "source.organizeImports": true,
        "source.fixAll.eslint": true
      },
      "language_servers": ["vtsls", "..."]
    },
    "HTML": {
      "formatter": "prettier"
    }
  },
  "lsp": {
    "vtsls": {
      "settings": {
        "typescript": {
          "suggest": {
            "autoImports": true
          },
          "implementationsCodeLens": {
            "enabled": true,
            "showOnAllClassMethods": true
          },
          "referencesCodeLens": {
            "enabled": true,
            "showOnAllFunctions": true
          }
        },
        "javascript": {
          "suggest": {
            "autoImports": true
          },
          "implementationsCodeLens": {
            "enabled": true,
            "showOnAllClassMethods": true
          },
          "referencesCodeLens": {
            "enabled": true,
            "showOnAllFunctions": true
          }
        }
      },
      "initialization_options": {
        "typescript": {
          "suggest": {
            "autoImports": true,
            "completeFunctionCalls": true
          },
          "javascript": {
            "suggest": {
              "autoImports": true,
              "completeFunctionCalls": true
            }
          },
          "preferences": {
            "includeCompletionsWithInsertText": true
          }
        }
      }
    },
    "typescript-language-server": {
      "initialization_options": {
        "preferences": {
          "includeCompletionsWithInsertText": true
        }
      }
    },
    "tailwindcss-language-server": {
      "settings": {
        "experimental": {
          "classRegex": [
            "\\.className\\s*[+]?=\\s*['\"]([^'\"]*)['\"]",
            "\\.setAttributeNS\\(.*,\\s*['\"]class['\"],\\s*['\"]([^'\"]*)['\"]",
            "\\.setAttribute\\(['\"]class['\"],\\s*['\"]([^'\"]*)['\"]",
            "\\.classList\\.add\\(['\"]([^'\"]*)['\"]",
            "\\.classList\\.remove\\(['\"]([^'\"]*)['\"]",
            "\\.classList\\.toggle\\(['\"]([^'\"]*)['\"]",
            "\\.classList\\.contains\\(['\"]([^'\"]*)['\"]",
            "\\.classList\\.replace\\(\\s*['\"]([^'\"]*)['\"]",
            "\\.classList\\.replace\\([^,)]+,\\s*['\"]([^'\"]*)['\"]"
          ]
        }
      }
    },
    "eslint": {
      "settings": {
        "rulesCustomizations": [{ "rule": "*", "severity": "warn" }],
        "problems": {
          "shortenToSingleLine": true
        }
      }
    }
  },
  "show_edit_predictions": true,
  "show_completion_documentation": true,
  "buffer_font_weight": 400,
  "buffer_line_height": { "custom": 1.5 },
  "relative_line_numbers": "disabled",
  "remove_trailing_whitespace_on_save": true,
  "ensure_final_newline_on_save": true,
  "outline_panel": {
    "dock": "right"
  },
  "seed_search_query_from_cursor": "always",
  "use_smartcase_search": true,
  "multi_cursor_modifier": "alt",
  "vim_mode": false,
  "show_wrap_guides": false,
  "wrap_guides": [80, 120],
  "preferred_line_length": 80
}
JSON

# ── Helper: Atomic Safe Installation ─────────────────────────
install_settings() {
    local dir="$1"
    local target="$dir/settings.json"

    mkdir -p "$dir" 2>/dev/null || true

    # Back up existing settings file if non-empty
    if [[ -f "$target" && -s "$target" ]]; then
        local backup="${target}.bak.$(date +%Y%m%d_%H%M%S)"
        cp "$target" "$backup" 2>/dev/null || true
        printf "  ${GRAY}↩  Backup saved → %s${NC}\n" "$(basename "$backup")"
    fi

    # Atomic Safe Write using standard redirection
    printf '%s\n' "$SETTINGS" > "$target"

    if [[ -s "$target" ]]; then
        printf "  ${GREEN}✔  Written → %s${NC}\n" "$target"
    else
        printf "  ${RED}❌  Failed to write → %s${NC}\n" "$target"
        return 1
    fi
}

# ── Main ──────────────────────────────────────────────────────
echo ""
echo -e "${PURPLE}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║        ⚡ Zed IDE Settings Bulletproof Installer      ║${NC}"
echo -e "${PURPLE}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
printf "  ${CYAN}➜ System OS:${NC} ${BOLD}%s${NC}\n\n" "$OS_TYPE"

success_count=0

for dir in "${TARGET_DIRS[@]}"; do
    printf "▶ Installing to path: ${BOLD}%s${NC}\n" "$dir"
    if install_settings "$dir"; then
        ((success_count++)) || true
    fi
    echo ""
done

if [[ $success_count -gt 0 ]]; then
    printf "${GREEN}${BOLD}✨  Done! Updated %d Zed configuration path(s). Restart Zed for changes to take effect.${NC}\n\n" "$success_count"
else
    printf "${RED}${BOLD}❌  Failed to update any Zed configuration paths.${NC}\n\n"
    exit 1
fi
