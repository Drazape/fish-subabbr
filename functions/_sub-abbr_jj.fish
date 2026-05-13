begin
    set --local exec_name jj
    set --local exec_section _{$exec_name}
    function _sub-abbr{$exec_section} --description='Sub-Command expansions for Jujutsu' --on-event=sub-abbr{s,$exec_section} --inherit-variable=exec_name
        set --function sub_abbr sub-abbr {$exec_name}
        $sub_abbr b{,ookmark}
        $sub_abbr c{i,ommit}
        $sub_abbr desc{,ribe}
        $sub_abbr st{,atus}
    end
end
