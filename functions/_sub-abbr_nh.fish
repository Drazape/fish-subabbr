begin
    set --local exec_name nh
    set --local exec_section _{$exec_name}
    function _sub-abbr{$exec_section} --description='Sub-Command expansions for nh' --on-event=sub-abbr{s,$exec_section} --inherit-variable=exec_name
        # os: allow root
        for subCommand in switch boot build{,-image,-vm} rollback test
            sub-abbr --set-cursor {$exec_name}\ os {$subCommand}{,' % --bypass-root-check'}
        end
    end
end
