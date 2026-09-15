if status is-interactive
    # CachyOS ships a base fish config (aliases, keybinds). Source it when present.
    if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
        source /usr/share/cachyos-fish-config/cachyos-config.fish
    end
end

function fish_greeting
end

# --- PATH ---
fish_add_path $HOME/.opencode/bin
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/go/bin

# Homebrew (macOS / Linuxbrew)
if test (uname) = Darwin
    if test -x /opt/homebrew/bin/brew
        /opt/homebrew/bin/brew shellenv | source
    else if test -x /usr/local/bin/brew
        /usr/local/bin/brew shellenv | source
    end
end

set -gx EDITOR nvim
set -gx NVM_DIR "$HOME/.nvm"

# --- tool init (guarded so a fresh box doesn't error before install) ---
type -q zoxide; and zoxide init fish | source
type -q starship; and starship init fish | source
type -q fzf; and fzf --fish | source

# Browser for puppeteer / chrome-devtools-mcp (Linux uses Helium)
if test (uname) != Darwin; and test -x /opt/helium-browser-bin/helium
    set -gx CHROME_PATH /opt/helium-browser-bin/helium
    set -gx PUPPETEER_EXECUTABLE_PATH /opt/helium-browser-bin/helium
end
