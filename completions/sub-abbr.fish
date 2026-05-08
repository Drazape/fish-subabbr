alias common-complete 'complete --command=sub-abbr --no-files'

common-complete
common-complete --long-option=color --description='When to colorize output' --exclusive --arguments='always never auto'
common-complete --short-option=h --long-option=help --description=Help
common-complete --short-option=f --long-option=function --description='Treat expansion argument as a fish function' --exclusive --arguments='(functions)'
common-complete --short-option=r --long-option=regex --description='Match a regular expression' --exclusive
common-complete --long-option=set-cursor --description='Position the cursor at % post-expansion'
common-complete --long-option=color --description='When to colorize output' --exclusive --arguments='always never auto'
common-complete --short-option=0 --long-option=norun0 --description='disable support for run0'
common-complete --short-option=s --long-option=regard-flags --description='Acknowledge flags in the Initial Command'
