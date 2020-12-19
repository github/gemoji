require 'mkmf'

$CFLAGS << ' -ggdb3 -O0 '

dir_config('gemoji')
create_makefile('gemoji')
