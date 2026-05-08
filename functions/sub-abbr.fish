function sub-abbr --description='Create abbreviations for subcommands'
    # arguments
    ## Switches
    ### Help (the only native switch)
    argparse --move-unknown --name=(set_color --dim)(status function)(set_color normal) 'a/add=*&' '/position=*&' 'f/function=*&' 'h/help&' '0/norun0&' -- {$argv} || return 1
    if set --query --local _flag_help
        function bullet --description='Create colored bullet points'
            echo (set_color --dim yellow)"$argv"(set_color normal)
        end
        function heading --description='Create headings for headers'
            echo (set_color --bold --underline --underline-color=brblue blue)"$argv":(set_color normal)
        end
        function header --description='Create headers for subheads'
            echo (set_color --bold green)"$argv"(set_color normal)
        end
        function subhead --description='Create an attribute set header'
            echo (set_color --italics green)"$argv"(set_color normal)
        end
        set --local sep \t(set_color --dim)'│ '(set_color normal)

        echo (set_color magenta)'Abbreviate subcommands'(set_color normal)\n\n\
(heading Arguments)\n \
            (bullet 1.) (header Base\ Command){$sep}'Comes before the' (set_color --italics)Sub-Command(set_color normal)'; flags are ignored by default'\n \
            (bullet 2.) (header Sub-Command)\t{$sep}'Comes after the' (set_color --italics)'Base Command'(set_color normal)'; replaced by the '(set_color --italics)Expansion(set_color normal)\n \
            (bullet 3.) (header Expansion)\t{$sep}'Replaces the '(set_color --italics)Sub-Command(set_color normal)\n\
(heading Switches)\n \
            (string repeat 6 \ )(set_color --underline --underline-color=brcyan --bold cyan)long\tshort(set_color normal)\n \
            (bullet •) (string repeat 4 \ )(subhead help\t'  'h){$sep}'Show this reference manual'\n \
            (bullet •) (string repeat 3 \ )(subhead norun0\t'  '0){$sep}Disable (set_color --background=red)run0(set_color normal) 'toleration for abbreviations'\n \
            (bullet •) (subhead regard-flags '  's){$sep}'Acknowledge flags in the' (set_color --italics)'Base command'(set_color normal)\n \
            (set_color white --dim)\((set_color normal --dim)'others compatible inherited from' (set_color --background=brblack)abbr(set_color --background=black white --dim)\)(set_color normal)
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
    function _expand-subcommand --description='Expand a subcommand' --argument-names={initial_command,expansion,subcommand} --inherit-variable=_flag_norun0
        set --function match_command {$initial_command}\ {$subcommand}
        set --query --local _flag_norun0 || set --local check_run0 'run0 '"$match_command"
        argparse --move-unknown -- (commandline --tokens-expanded --current-process)
        string match --quiet "$argv" {$match_command} {$check_run0} && echo {$expansion}
    end
    function {$func_name} --argument-names=subcommand --inherit-variable={initial_command,expansion}
        _expand-subcommand {$initial_command} {$expansion} {$subcommand}
    end
end
