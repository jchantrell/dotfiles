function brew-install --description 'Fuzzy-finder TUI for picking Homebrew formulae to install'
    set pkg_names (brew formulae | fzf \
        --multi \
        --preview 'brew info {1}' \
        --preview-label='alt-p: toggle description, alt-j/k: scroll, tab: multi-select' \
        --preview-label-pos='bottom' \
        --preview-window 'down:65%:wrap' \
        --bind 'alt-p:toggle-preview' \
        --bind 'alt-d:preview-half-page-down,alt-u:preview-half-page-up' \
        --bind 'alt-k:preview-up,alt-j:preview-down' \
        --color 'pointer:green,marker:green')

    if test -n "$pkg_names"
        brew install $pkg_names
    end
end
