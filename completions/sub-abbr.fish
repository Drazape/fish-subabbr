alias common-complete 'complete --command=sub-abbr --no-files'

common-complete
common-complete --short-option=h --long-option=help --description=Help
common-complete --short-option=c --long-option=set-cursor --description='Position the cursor at % post-expansion'
common-complete --short-option=0 --long-option=norun0 --description='disable support for run0'
common-complete --short-option=s --long-option=regard-flags --description='Acknowledge flags in the Initial Command'
