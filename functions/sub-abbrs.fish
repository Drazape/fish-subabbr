function sub-abbrs --description='Repository of sub-abbrs'
    argparse --name=(set_color --dim)(status current-function)(set_color normal) 'f/from=&!contains {$_flag_value} official installed' -- {$argv}

    if test (count {$argv}) = 0 # Call all
        test "$_flag_from" != installed && for pkg in (path basename --no-extension {$fish_function_path}/* | string match --regex --entire '^_sub-abbr_')
            { $pkg }
        end
        test "$_flag_from" != official && emit sub-abbrs
    else
        for subAbbr_base in sub-abbr_{$argv}
            test "$_flag_from" != installed && begin
                set --local repo_func _{$subAbbr_base}
                functions --query {$repo_func} && { $repo_func }
            end
            test "$_flag_from" != official && emit {$subAbbr_base}
        end
    end
end
