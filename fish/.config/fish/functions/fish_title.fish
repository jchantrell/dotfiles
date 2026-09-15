function fish_title
    set -l path (string replace $HOME '~' $PWD)
    set -l parts (string split '/' $path)
    if test (count $parts) -gt 3
        set parts $parts[-3..-1]
    end
    string join '/' $parts
end
