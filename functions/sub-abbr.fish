function sub-abbr --description='Create abbreviations for subcommands'
    set --local output_name (set_color --dim)(status function)(set_color normal)

    # arguments
    ## Switches
    argparse --name={$output_name} 'r/regex&' 'c/set-cursor=?&' 'h/help&' '0/norun0&' s/regard-flags -- {$argv} || return 1
    ### Set Cursor
    if test -z {$_flag_set_cursor}
        set -- set_cursor --set-cursor
    else
        set -- set_cursor --set-cursor={$_flag_set_cursor}
    end
    ### Help (the only native switch)
    if set --query --local _flag_help
        set --local inherited \ (set_color white)'(inherited from '(set_color normal)(set_color --background=red)abbr(set_color normal)(set_color white)\)(set_color normal)
        help-text 'Abbreviate subcommands' \
            --positional={
                  'Base Command | Comes before the Sub-Command; flags are ignored by default', 
                  'Sub-Command | Comes after the Base Command; replaced by the Expansion',
                  'Expansion | Replaces the Sub-Command'
            } \
            --switch={
                'help:h | Show this reference manual',
                'norun0:0 | Disable '(set_color --background=red)run0(set_color normal)' toleration for abbreviations',
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
        if test (count {$argv}) -ne 3
            echo {$output_prefix} expected (set_color --bold)3(set_color normal) arguments(set_color white)\;(set_color normal) got (set_color --italics)(count {$argv})(set_color normal)
            return 3
        end
        ### Name arguments (`--argument-names` is not used for compatibility with `argparse`)
        set --function base_command {$argv[1]}
        set --function subcommand {$argv[2]}
        set --function expansion {$argv[3]}
        ### compatible subcommand name: must be a single token
        begin
            function subcommand-contains --argument-names=substring --inherit-variable=subcommand
                test (count {$argv}) -eq 1 || return 1
                string match --quiet --regex '.*'{$substring}'.*' {$subcommand}
            end
            if subcommand-contains ' ' || subcommand-contains \n
                echo {$output_name} incompatible (set_color --italics)Sub-Command(set_color normal)
                return 4
            end
        end
    end

    # main operation
    set --function identity (systemd-escape _sub-attr_expand_{$base_command}\ {$subcommand}) # name compatible hash; specific to the combination
    begin
        set --local -- common_flags {$set_cursor} --add --position=anywhere --function={$identity}
        if set --query --local _flag_regex
            abbr {$common_flags} --regex="$subcommand" -- {$identity}
        else
            abbr {$common_flags} -- "$subcommand"
        end
    end
    function _expand-subcommand --description='Expand a subcommand' --argument-names={base_command,expansion,subcommand} --inherit-variable=_flag_{norun0,regard_flags}
        set --function match_command {$base_command}\ {$subcommand}
        set --query --local _flag_norun0 || set --local check_run0 'run0 '"$match_command"
        set --function argv (commandline --tokens-expanded --current-process)
        set --local --query _flag_regard_flags || argparse --move-unknown -- {$argv}
        string match --quiet "$argv" {$match_command} {$check_run0} && echo {$expansion}
    end
    function {$identity} --argument-names=subcommand --inherit-variable={base_command,expansion}
        _expand-subcommand {$base_command} {$expansion} {$subcommand}
    end
end
