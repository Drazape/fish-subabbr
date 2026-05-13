function sub-abbrs --description='Repository of sub-abbrs'
    if test (count {$argv}) = 0 # Call all
        emit sub-abbrs
        for pkg in (path basename --no-extension {$fish_function_path}/* | string match --regex --entire '^_sub-abbr_')
            { $pkg }
        end
    else
        for subAbbr_base in sub-abbr_{$argv}
            emit {$subAbbr_base}
            begin
                set --local repo_func _{$subAbbr_base}
                functions --query {$repo_func} && { $repo_func }
            end
        end
    end
end
