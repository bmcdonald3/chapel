use Time;
require 'libdivide.h';

extern record libdivide_s64_t {
  var magic: int;
  var more: uint(8);
}
extern proc libdivide_s64_gen(a): libdivide_s64_t;
extern proc libdivide_s64_do(a, ref b): int;
                                  
config const numOps=1000000000;

var sum = 0;
var t: stopwatch;
var asd: libdivide_s64_t;
asd = libdivide_s64_gen(10);
t.start();
for i in 1..numOps {
  sum+=libdivide_s64_do(i, asd);
}
writeln(sum);
t.stop();
writeln("libdivide took: ", t.elapsed());

sum = 0;
t.clear();
t.start();

for i in 1..numOps {
  sum += (i/10);
}
writeln(sum);
t.stop();
writeln("regular divide took: ", t.elapsed());
