function _sub-abbr_jj --description='subcommand expansions for Jujutsu' --on-event=sub-abbr{s,_jj}
    set --function sub_abbr sub-abbr jj
    $sub_abbr b{,ookmark}
    $sub_abbr c{i,ommit}
    $sub_abbr desc{,ribe}
    $sub_abbr st{,atus}
end
