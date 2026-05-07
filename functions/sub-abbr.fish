function sub-abbr --description='Create abbreviations for subcommands' --argument-names={initial_command,subcommand,replacement}
    alias print 'echo (set_color --dim)(status function)(set_color normal):'

    # argument checks
    ## maximum arguments
    if test (count {$argv}) -ne 3
        print expected (set_color --bold)3(set_color normal) 'arguments; got' (set_color --italics)(count {$argv})(set_color normal)
        return 1
    end
    ## compatible subcommand name: must be a single token
    begin
        function subcommand-contains
            test (count {$argv}) -eq 1 || return 1
            string match --quiet --regex '.*'{$argv}'.*' {$subcommand}
        end
        if subcommand-contains ' ' || subcommand-contains \n
            print 'incompatible subcommand'
            return 2
        end
    end

    # main operation
    set --function func_name _sub-attr_(string replace --all ' ' - {$initial_command})_{$subcommand} # function name compatible hash, specific to the combination
    abbr --add --position=anywhere --set-cursor "$subcommand" --function={$func_name}
    function {$func_name} --inherit-variable={initial_command,replacement} # `subcommand` is passed as an argument by Fish
        test (commandline --current-process | string trim) = {$initial_command}\ {$argv} && echo {$replacement}
    end
end
