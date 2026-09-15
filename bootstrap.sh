#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO"

# Runtime-heavy dirs use --no-folding so the app can still write its own state
# (sessions, fisher plugins, caches) into the real dir alongside our symlinks.
STOW_PACKAGES=(fish nvim wezterm starship btop zed git claude opencode)

log()  { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }

os="$(uname)"

install_packages_macos() {
  if ! command -v brew >/dev/null 2>&1; then
    log "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
  fi
  log "brew bundle"
  brew bundle --file="$REPO/packages/Brewfile"
  install_awscli_macos
}

install_awscli_macos() {
  if command -v aws >/dev/null 2>&1; then return; fi
  log "Installing AWS CLI v2 (official pkg — avoids Homebrew python/expat breakage)"
  local pkg
  pkg="$(mktemp -t awscliv2)".pkg
  if curl -fsSL "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "$pkg" \
    && sudo installer -pkg "$pkg" -target /; then
    rm -f "$pkg"
  else
    warn "AWS CLI install failed — see https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
  fi
}

install_packages_linux() {
  log "Installing repo packages (pacman)"
  grep -vE '^\s*(#|$)' "$REPO/packages/pacman.txt" | sudo pacman -S --needed --noconfirm -
  if command -v yay >/dev/null 2>&1; then
    log "Installing AUR packages (yay)"
    grep -vE '^\s*(#|$)' "$REPO/packages/aur.txt" | yay -S --needed --noconfirm -
  else
    warn "yay not found — skipping AUR packages (see packages/aur.txt)"
  fi
}

case "$os" in
  Darwin) install_packages_macos ;;
  Linux)  install_packages_linux ;;
  *) warn "Unknown OS '$os' — skipping package install" ;;
esac

if ! command -v stow >/dev/null 2>&1; then
  warn "stow is missing after the package step — cannot symlink configs"; exit 1
fi

log "Symlinking configs with stow"
for pkg in "${STOW_PACKAGES[@]}"; do
  stow --no-folding --restow -t "$HOME" "$pkg"
done

if command -v fish >/dev/null 2>&1; then
  log "Installing fish plugins (fisher reads fish_plugins)"
  fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; fisher update' \
    || warn "fisher install failed — run 'fisher update' in fish later"
  log "Installing LTS node + Claude Code via nvm.fish"
  fish -c 'nvm install lts; and npm install -g @anthropic-ai/claude-code' \
    || warn "node/claude-code install failed — run: nvm install lts; npm install -g @anthropic-ai/claude-code"
fi

if command -v bun >/dev/null 2>&1 && [ -d "$HOME/.claude/mcp-servers/repo-tools" ]; then
  log "Installing repo-tools MCP server deps"
  (cd "$HOME/.claude/mcp-servers/repo-tools" && bun install) || warn "bun install failed"
fi

# Register user-scope MCP servers (writes to ~/.claude.json, which Claude reads).
# $HOME is expanded now, so the stored path is correct on any machine.
if command -v claude >/dev/null 2>&1; then
  log "Registering MCP servers (claude, user scope)"
  claude mcp add --scope user repo-tools -- bun run "$HOME/.claude/mcp-servers/repo-tools/index.ts" 2>/dev/null || true
  claude mcp add --scope user chrome-devtools -- npx -y chrome-devtools-mcp@latest 2>/dev/null || true
  claude mcp add --scope user --transport http context7 https://mcp.context7.com/mcp 2>/dev/null || true
else
  warn "claude CLI not found — register MCP servers later (see README)"
fi

if command -v nvim >/dev/null 2>&1; then
  log "Syncing neovim plugins from lockfile"
  nvim --headless "+Lazy! restore" +qa 2>/dev/null || warn "nvim plugin sync failed"
fi

if command -v fish >/dev/null 2>&1; then
  fish_path="$(command -v fish)"
  if ! grep -qxF "$fish_path" /etc/shells 2>/dev/null; then
    log "Adding fish to /etc/shells"
    echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
  fi
  if [ "${SHELL:-}" != "$fish_path" ]; then
    log "Setting fish as the default shell"
    chsh -s "$fish_path" || warn "chsh failed — set the default shell manually"
  fi
fi

cat <<'EOF'

==> Bootstrap complete. Manual follow-ups:
  * Install the "Codelia" terminal font (paid; wezterm falls back to a Nerd Font otherwise).
  * gh auth login              # GitHub credential helper
  * Restore ~/.ssh keys        # if you sign commits
  * Restart the terminal so fish + PATH changes take effect.
EOF
