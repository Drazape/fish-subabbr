#!/usr/bin/env fish
# Only allow execution as root
if ! fish_is_root_user
    echo (status basename)': Must be ran as root'
    return 1
end

# Setup Cleanup
function cleanup_temporary_repository --description='Nuke temporary repository on exit' --on-event=fish_exit
    rm -rf -- {$repository_dir}
end

# Clone repository to temporary directory
set --global -- repository_dir (mktemp --directory /tmp/"$(string split '/' "$REPOSITORY" | tail -n 1)"-'XXXXXXXXX')
begin
    set --local clone_repo clone --filter=blob:none https://github.com/Drazape/fish-subAbbr.git "$repository_dir"
    git $clone_repo || nix run nixpkgs#git $clone_repo || return 2
end
cd {$repository_dir}

# Operate
## Functions
set --local functions_dir /usr/local/share/fish/vendor_functions.d
### Functions' path for root
if ! set -ql _flag_vendor
    set --local global_fish_config_path /etc/fish/conf.d/local-functions.fish
    # Preparation
    mkdir -p -- (path dirname {$global_fish_config_path})
    # Main file
    echo 'if ! contains '"$functions_dir"' {$fish_function_path}
'\t'set --prepend fish_function_path '"$functions_dir"'
end' | tee {$global_fish_config_path} >/dev/null
end

set --function installFile sub-abbr.fish
### Install
install -D --mode=644 -- functions/{$installFile} {$functions_dir}/{$installFile}

## Completion
install -D --mode=644 {$VERBOSE} -- completions/{$installFile} /usr/local/share/fish/vendor_completions.d/{$installFile}
