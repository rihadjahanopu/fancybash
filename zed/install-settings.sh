#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Zed IDE — settings installer
#  Writes settings.json to both the Flatpak and native config paths.
#  Usage: bash install-settings.sh
# ─────────────────────────────────────────────────────────────

set -euo pipefail

# ── Target paths ──────────────────────────────────────────────
FLATPAK_DIR="$HOME/.var/app/dev.zed.Zed/config/zed"
NATIVE_DIR="$HOME/.config/zed"

# ── Settings payload ──────────────────────────────────────────
read -r -d '' SETTINGS <<'JSON' || true

{

  "cli_default_open_behavior": "existing_window",
  "code_lens": "on",
  "bottom_dock_layout": "contained",
  "colorize_brackets": true,

  "indent_guides": {
    "background_coloring": "disabled",
  },
  "agent_servers": {
    "opencode": {
      "type": "registry",
    },
  },
  "agent": {
    "dock": "right",
    "favorite_models": [],
    "model_parameters": [],
  },
  "instrumentation": {
    "performance_profiler": {
      "enabled": true,
    },
  },
  "proxy": "",
  "focus_follows_mouse": {
    "enabled": true,
  },
  "which_key": {
    "enabled": false,
  },
  "icon_theme": {
    "mode": "dark",
    "light": "Material Icon Theme",
    "dark": "Material Icon Theme",
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
  "hover_popover_delay": 0,
  "ui_font_family": "Cascadia Code",
  "ui_font_size": 20,
  "buffer_font_size": 22.0,
  "buffer_font_family": "Cascadia Code",
  "buffer_font_fallbacks": ["JetBrains Mono", "Fira Code"],
  "session": {
    "trust_all_worktrees": true,
  },
  "project_panel": {
    "dock": "left",
    "auto_fold_dirs": false,
    "hide_root": false,
    "git_status_indicator": true,
    "diagnostic_badges": true,
    "bold_folder_labels": true,
  },
  "preview_tabs": {
    "enabled": true,
    "enable_preview_from_file_finder": true,
    "enable_preview_multibuffer_from_code_navigation": true,
  },
  "status_bar": {
    "line_endings_button": true,
    "experimental.show": true,
    "show_active_file": true,
  },
  "sticky_scroll": {
    "enabled": false,
  },
  "minimap": {
    "show": "always",
  },
  "scrollbar": {
    "axes": {
      "horizontal": true,
    },
  },
  "file_types": {
    "html": ["*html", "*njk", "*.ejs"],
  },
  "theme": {
    "mode": "dark",
    "light": "Everforest Light Hard (blur)",
    "dark": "Zedokai (Filter Spectrum)",
  },
  "terminal": {
    "font_weight": 400.0,
    "copy_on_select": true,
    "blinking": "on",
    "cursor_shape": "block",
    "line_height": {
      "custom": 1.3,
    },
    "font_fallbacks": ["JetBrains Mono", "FiraCode Nerd Font"],
    "font_family": "Cascadia Code",
    "font_size": 22.0,
    "env": {
      "LD_LIBRARY_PATH": "",
    },
    "toolbar": {
      "breadcrumbs": true,
    },
    "show_count_badge": true,
  },
  "git": {
    "inline_blame": {
      "show_commit_summary": true,
    },
  },
  "notification_panel": {
    "show_count_badge": true,
  },
  "git_panel": {
    "tree_view": true,
    "sort_by_path": true,
    "show_count_badge": true,
    "file_icons": true,
  },
  "tabs": {
    "file_icons": true,
    "git_status": true,
  },
  "title_bar": {
    "button_layout": "platform_default",
    "show_menus": false,
    "show_branch_status_icon": true,
  },
  "diagnostics": {
    "inline": {
      "enabled": true,
      "max_severity": "all",
    },
  },
  "prettier": {
    "allowed": true,
  },
  "inlay_hints": {
    "show_background": true,
    "enabled": true,
  },
  "toolbar": {
    "code_actions": true,
  },

  "format_on_save": "on",
  "formatter": "prettier",
  "languages": {
    "JavaScript": {
      "code_actions_on_format": {
        "source.organizeImports": true,
      },
    },
    "TypeScript": {
      "code_actions_on_format": {
        "source.organizeImports": true,
        "source.fixAll.eslint": true,
      },
    },
    "TSX": {
      "code_actions_on_format": {
        "source.organizeImports": true,
        "source.fixAll.eslint": true,
      },
    },
    "HTML": {
      "formatter": "prettier",
    },
  },

  "lsp": {
    "vtsls": {
      "settings": {
        "typescript": {
          "implementationsCodeLens": {
            "enabled": true,
            "showOnAllClassMethods": true,
          },
          "referencesCodeLens": {
            "enabled": true,
            "showOnAllFunctions": true,
          },
        },
      },
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
            "\\.classList\\.replace\\([^,)]+,\\s*['\"]([^'\"]*)['\"]",
          ],
        },
      },
    },

    "eslint": {
      "settings": {
        "rulesCustomizations": [
          // set all eslint errors/warnings to show as warnings
          { "rule": "*", "severity": "warn" },
        ],
        "problems": {
          "shortenToSingleLine": true,
        },
      },
    },
  },

  "show_edit_predictions": true,
}



JSON

# ── Helper ────────────────────────────────────────────────────
install_settings() {
  local dir="$1"
  local target="$dir/settings.json"

  mkdir -p "$dir"

  # Back up existing file if present
  if [[ -f "$target" ]]; then
    local backup="${target}.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$target" "$backup"
    echo "  ↩  Backup saved → $backup"

    # Clear the existing file contents
    > "$target"
    echo "  🧹  Existing settings cleared"
  fi

  # Write via curl (file:// protocol — no network needed)
  printf '%s\n' "$SETTINGS" | curl --silent --show-error \
    --upload-file - \
    "file://$target" 2>/dev/null || {
      # curl file:// upload is not universally supported; fall back to tee
      printf '%s\n' "$SETTINGS" | tee "$target" > /dev/null
    }

  echo "  ✔  Written → $target"
}

# ── Main ──────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║      Zed Settings Installer              ║"
echo "╚══════════════════════════════════════════╝"
echo ""

echo "▶ Installing to Flatpak path …"
install_settings "$FLATPAK_DIR"

echo ""
echo "▶ Installing to native config path …"
install_settings "$NATIVE_DIR"

echo ""
echo "✅  Done! Restart Zed for changes to take effect."
echo ""
