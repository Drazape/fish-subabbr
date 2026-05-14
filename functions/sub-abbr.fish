function sub-abbr --description='Create abbreviations for subcommands'
    set --local output_name (set_color --dim)(status function)(set_color normal)

    # arguments
    ## Switches
    argparse --name={$output_name} 'r/regex&' 'c/set-cursor=?&' 'h/help&' '0/no-run0&' 's/regard-flags&' -- {$argv} || return 1
    ### Set Cursor
    set --query --local _flag_set_cursor && if test -z {$_flag_set_cursor}
        set -- set_cursor --set-cursor
    else
        set -- set_cursor --set-cursor={$_flag_set_cursor}
    end
    ### Help (the only native switch)
    if set --query --local _flag_help
        set --local inherited \ (set_color white)'(inherited from '(set_color normal)(set_color --background=red)abbr(set_color normal)(set_color white)\)(set_color normal)
        help-text 'Abbreviate subcommands' \
            --positional={
                  '+Initial Args | All arguments that come before the Sub-Command', 
                  'Sub-Command | Comes after the Base Command; replaced by the Expansion',
                  'Expansion | Replaces the Sub-Command'
            } \
            --switch={
                'help:h | Show this reference manual',
                'no-run0:0 | Disable '(set_color --background=red)run0(set_color normal)' toleration for abbreviations',
                'regard-flags:s | Acknowledge flags in the Base Command',
                'set-cursor:c | Position the cursor at '(set_color --background=brblack)%(set_color normal)' post-expansion'{$inherited},
                'regex:r | Match Sub-Command with Regex. Essential for multiple Base Commands'{$inherited}
            }
        return
    end
    ## Positional
    begin
        set --local output_prefix {$output_name}(set_color --dim white):(set_color normal)
        ### appropriate number of arguments. Not using `argparse` so that `--help can have as many arguments as it wants` and better formatted output
        if test (count {$argv}) -lt 3
            echo {$output_prefix} expected (set_color --bold)2+(set_color normal) arguments(set_color white)\;(set_color normal) got (set_color --italics)(count {$argv})(set_color normal)
            return 3
        end
        ### Name arguments
        set --function base_command {$argv[1]}
        set --function initial_args {$argv[2..-3]}
        set --function subcommand {$argv[-2]}
        set --function expansion {$argv[-1]}
        ### compatible subcommand name: must be a single token
        begin
            function subcommand-contains --argument-names=substring --inherit-variable=subcommand
                test (count {$argv}) -eq 1 || return 1
                string match --quiet --regex '.*'{$substring}'.*' {$subcommand}
            end
            if subcommand-contains ' ' || subcommand-contains \n
                echo {$output_name} incompatible (set_color --italics)Sub-Command(set_color normal)
                return 3
            end
        end
    end

    # main operation
    set --function identity (systemd-escape _sub-attr_expand_"$base_command $initial_args $subcommand") # name compatible hash; specific to the combination
    begin
        set --query --local _flag_no_run0 || set --local -- tolerate_run0 --command=run0
        set --local -- common_flags --add --command={$base_command} {$tolerate_run0} --function={$identity} {$set_cursor}
        if set --query --local _flag_regex
            abbr {$common_flags} --regex="$subcommand" -- {$identity}
        else
            abbr {$common_flags} -- "$subcommand"
        end
    end
    function _expand-subcommand --description='Expand a subcommand'
        argparse '0/no-run0&' 's/regard-flags&' -- {$argv}
        set --function expansion {$argv[1]}
        set --function initial_args {$argv[2..]}
        set --local argv (commandline --tokens-expanded --current-process)
        set --local --query _flag_regard_flags || argparse --move-unknown -- {$argv}
        set --function arg_count (count {$initial_args})
        set --function active_sub_args {$argv[2..-2]}
        ! set --local --query _flag_no_run0 && test {$argv[1]} = run0 && set --function active_sub_args {$active_sub_args[2..]} # Remove real Base Command from sub arguments

        test {$arg_count} -eq (count {$active_sub_args}) || return 1
        for i in (seq 1 {$arg_count})
            test {$initial_args[$i]} = {$active_sub_args[$i]} || return 2
        end
        echo {$expansion}
    end
    function {$identity} --argument-names=subcommand --inherit-variable={expansion,initial_args,_flag_{no_run0,regard_flags}}
        _expand-subcommand {$_flag_no_run0} {$_flag_regard_flags} -- {$expansion} {$initial_args}
    end
end
