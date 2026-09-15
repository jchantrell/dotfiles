# Portable aliases so macOS matches the CachyOS base config.
# On Linux these are also set by cachyos-config.fish (sourced later, identical).

if type -q eza
    alias ls 'eza -al --color=always --group-directories-first --icons=always'
    alias la 'eza -a --color=always --group-directories-first --icons=always'
    alias ll 'eza -l --color=always --group-directories-first --icons=always'
    alias lt 'eza -aT --color=always --group-directories-first --icons=always'
    alias l. "eza -a | grep -e '^\.'"
end

alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'
alias grep 'grep --color=auto'
