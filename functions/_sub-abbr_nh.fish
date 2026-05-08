function _sub-abbr_nh --description='subcommand expansions for nh' --on-event=sub-abbr{s,_nh}
    # os: allow root
    for subCommand in switch boot build{,-image,-vm} rollback test
        sub-abbr --set-cursor 'nh os' {$subCommand}{,' % --bypass-root-check'}
    end
end
