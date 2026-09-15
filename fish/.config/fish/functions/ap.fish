function ap --description 'Set the active AWS_PROFILE (no arg: show current)'
    if test (count $argv) -eq 0
        echo $AWS_PROFILE
        return
    end
    set -gx AWS_PROFILE $argv[1]
end
