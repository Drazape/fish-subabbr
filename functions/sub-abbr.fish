function sub-abbr --description='Create abbreviations for subcommands'
    # arguments
    ## Switches
    argparse --name=(set_color --dim)(status function)(set_color normal) 'c/set-cursor=?&' 'h/help&' '0/norun0&' -- {$argv} || return 1
    ### Set Cursor
    if test -z {$_flag_set_cursor}
        set -- set_cursor --set-cursor
    else
        set -- set_cursor --set-cursor={$_flag_set_cursor}
    end
    ### Help (the only native switch)
    if set --query --local _flag_help
        help-text 'Abbreviate subcommands' \
            --positional={
                  'Base Command | Comes before the '(set_color --italics)Sub-Command(set_color normal)'; flags are ignored by default', 
                  'Sub-Command | Comes after the '(set_color --italics)Base\ Command(set_color normal)'; replaced by the '(set_color --italics)Expansion(set_color normal),
                  'Expansion | Replaces the '(set_color --italics)Sub-Command(set_color normal) } \
            --switch={
                'help:h | Show this reference manual',
                'norun0:0  | Disable '(set_color --background=red)run0(set_color normal)' toleration for abbreviations',
                'regard-flags:s | Acknowledge flags in the' (set_color --italics)'Base command'(set_color normal),
                'set-cursor:c | Position the cursor at '(set_color --background=brblack)%(set_color normal)' post-expansion '(set_color white)'(inherited from '(set_color normal)(set_color --background=red)abbr(set_color normal)(set_color white)\)(set_color normal) }
        return
    end
    ## Positional
    ### appropriate number of arguments. Not using `argparse` so that `--help can have as many arguments as it wants` and better formatted output
    if test (count {$argv}) -ne 3
        echo expected (set_color --bold)3(set_color normal) arguments(set_color white)\;(set_color normal) got (set_color --italics)(count {$argv})(set_color normal)
        return 3
    end
    ### Name arguments (`--argument-names` is not used for compatibility with `argparse`)
    set --function base_command {$argv[1]}
    set --function subcommand {$argv[2]}
    set --function expansion {$argv[3]}
    ### compatible subcommand name: must be a single token
    begin
        function subcommand-contains
            test (count {$argv}) -eq 1 || return 1
            string match --quiet --regex '.*'{$argv}'.*' {$subcommand}
        end
        if subcommand-contains ' ' || subcommand-contains \n
            echo 'incompatible subcommand'
            return 4
        end
    end

    # main operation
    set --function func_name (systemd-escape _sub-attr_expand_{$base_command}\ {$subcommand}) # function name compatible hash, specific to the combination
    abbr {$set_cursor} --add --position=anywhere --function={$func_name} -- "$subcommand"
    function _expand-subcommand --description='Expand a subcommand' --argument-names={base_command,expansion,subcommand} --inherit-variable=flag_norun0
        set --function match_command {$base_command}\ {$subcommand}
        set --query --local _flag_norun0 || set --local check_run0 'run0 '"$match_command"
        argparse --move-unknown -- (commandline --tokens-expanded --current-process)
        string match --quiet "$argv" {$match_command} {$check_run0} && echo {$expansion}
    end
    function {$func_name} --argument-names=subcommand --inherit-variable={base_command,expansion}
        _expand-subcommand {$base_command} {$expansion} {$subcommand}
    end
end
