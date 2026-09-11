#!/usr/bin/env bash
set -euo pipefail

# Universal Skills Installer for AI Coding Agent Harnesses
# Supports: Antigravity CLI, Claude Code, OpenCode

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="${SCRIPT_DIR}/skills"

HARNESS="all"
SCOPE="global"
MODE="link" # link or copy

print_help() {
  cat << 'HELP'
Universal Agent Skills Installer

Usage:
  ./scripts/install.sh [options]

Options:
  --harness <all|antigravity|claude|opencode>
      Target agent harness (default: all).
  --global
      Install into user home directory configuration (default).
  --local
      Install into current working directory (workspace).
  --link
      Symlink skills so edits in this repo reflect immediately (default).
  --copy
      Copy skill directories instead of symlinking.
  -h, --help
      Show this help message.

Examples:
  ./scripts/install.sh --harness all --global --link
  ./scripts/install.sh --harness antigravity --local --copy
HELP
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --harness)
      HARNESS="$2"
      shift 2
      ;;
    --global)
      SCOPE="global"
      shift
      ;;
    --local)
      SCOPE="local"
      shift
      ;;
    --link)
      MODE="link"
      shift
      ;;
    --copy)
      MODE="copy"
      shift
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      print_help
      exit 1
      ;;
  esac
done

install_to_dir() {
  local target_dir="$1"
  local harness_name="$2"
  
  echo "==> Installing skills for ${harness_name} into: ${target_dir}"
  mkdir -p "${target_dir}"
  
  for skill_path in "${SKILLS_SRC}"/*; do
    if [[ -d "${skill_path}" ]]; then
      local skill_name
      skill_name="$(basename "${skill_path}")"
      local dest="${target_dir}/${skill_name}"
      
      if [[ "${MODE}" == "link" ]]; then
        rm -rf "${dest}"
        ln -sf "${skill_path}" "${dest}"
        echo "  [Linked] ${skill_name} -> ${dest}"
      else
        rm -rf "${dest}"
        cp -r "${skill_path}" "${dest}"
        echo "  [Copied] ${skill_name} -> ${dest}"
      fi
    fi
  done
}

# Determine target directories based on harness and scope
if [[ "${HARNESS}" == "all" || "${HARNESS}" == "antigravity" ]]; then
  if [[ "${SCOPE}" == "global" ]]; then
    install_to_dir "${HOME}/.agents/skills" "Antigravity CLI (Global)"
  else
    install_to_dir "./.agents/skills" "Antigravity CLI (Local Workspace)"
  fi
fi

if [[ "${HARNESS}" == "all" || "${HARNESS}" == "claude" ]]; then
  if [[ "${SCOPE}" == "global" ]]; then
    install_to_dir "${HOME}/.claude/skills" "Claude Code (Global)"
  else
    install_to_dir "./.claude/skills" "Claude Code (Local Workspace)"
  fi
fi

if [[ "${HARNESS}" == "all" || "${HARNESS}" == "opencode" ]]; then
  if [[ "${SCOPE}" == "global" ]]; then
    install_to_dir "${HOME}/.opencode/skills" "OpenCode (Global)"
  else
    install_to_dir "./.opencode/skills" "OpenCode (Local Workspace)"
  fi
fi

echo ""
echo "✨ Installation complete! Skills are active in selected harnesses."
