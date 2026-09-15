function pkg-install --description 'Show a fuzzy-finder TUI for picking new Arch and OPR packages to install'
    set pkg_names (pacman -Slq | fzf \
        --multi \
        --preview 'pacman -Sii {1}' \
        --preview-label='alt-p: toggle description, alt-j/k: scroll, tab: multi-select' \
        --preview-label-pos='bottom' \
        --preview-window 'down:65%:wrap' \
        --bind 'alt-p:toggle-preview' \
        --bind 'alt-d:preview-half-page-down,alt-u:preview-half-page-up' \
        --bind 'alt-k:preview-up,alt-j:preview-down' \
        --color 'pointer:green,marker:green')

    if test -n "$pkg_names"
        sudo pacman -S --noconfirm $pkg_names
    end
end
