use OS.POSIX;
use IO.FormattedIO;
var tv: timeval;
writeln(gettimeofday(tv, nil));
writeln('%i.%06i'.format(tv.tv_sec:int, tv.tv_usec:int));
