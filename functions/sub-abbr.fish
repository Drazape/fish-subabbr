function sub-abbr --description='Create abbreviations for subcommands'
    # arguments
    ## Switches
    ### Help (the only native switch)
    argparse --move-unknown --name=(set_color --dim)(status function)(set_color normal) 'a/add=*&' '/position=*&' 'f/function=*&' 'h/help&' -- {$argv} || return 1
    if set --query --local _flag_help
        function bullet --description='Create colored bullet points'
            echo (set_color --dim yellow){$argv}.(set_color normal)
        end
        function header --description='Create headers'
            echo (set_color --bold green){$argv}(set_color normal)
        end

        echo (set_color magenta)'Set abbreviations on subcommands'(set_color normal)\n\n\
(set_color blue --bold --underline)'Arguments:'(set_color normal)\n \
            (bullet 1) (header Initial\ Command)\t'Comes before the subcommand'\n \
            (bullet 2) (header Sub-Command)\t\t'Comes after the initial command; replaced by the expansion'\n \
            (bullet 3) (header Expansion)\t\t'Replaces the subcommand'
        return
    end
    ### Unsupported switches
    if set -ql _flag_add || set -ql _flag_position || set -ql _flag_function
        echo (set_color red)'cannot pass internally used switches:' (set_color --bold)'add position function'(set_color normal)
        return 2
    end
    ## Positional
    ### appropriate number of arguments. Not using `argparse` so that `--help can have as many arguments as it wants` and better formatted output
    if test (count {$argv}) -ne 3
        echo expected (set_color --bold)3(set_color normal) 'arguments; got' (set_color --italics)(count {$argv})(set_color normal)
        return 3
    end
    ### Name arguments (`--argument-names` is not used for compatibility with `argparse`)
    set --function initial_command {$argv[1]}
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
    set --function func_name _sub-attr_(string replace --all ' ' - {$initial_command})_{$subcommand} # function name compatible hash, specific to the combination
    abbr {$argv_opts} --add --position=anywhere --function={$func_name} -- "$subcommand"
    function _expand-subcommand --description='Expand a subcommand' --argument-names={initial_command,expansion,subcommand}
        string match --quiet (commandline --current-process) {,run0\ }{$initial_command}\ {$subcommand}' ' && echo {$expansion}
    end
    function {$func_name} --argument-names=subcommand --inherit-variable={initial_command,expansion}
        _expand-subcommand {$initial_command} {$expansion} {$subcommand}
    end
end
