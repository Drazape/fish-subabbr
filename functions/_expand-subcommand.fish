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
