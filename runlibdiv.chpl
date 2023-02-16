use Time;
require 'libdivide.h';

extern record libdivide_s64_t {
  var magic: int;
  var more: uint(8);
}
extern proc libdivide_s64_gen(a): libdivide_s64_t;
extern proc libdivide_s64_do(a, ref b): int;
                                  
config const numOps=1000000000;
config const trials = 5;
config const libDiv = true;

proc main() {
  if libDiv then
    runLibDiv();
  else
    runChapelDiv();
}

proc runLibDiv() {
  var denom: libdivide_s64_t = libdivide_s64_gen(10);
  for j in 1..trials {
    var sum = 0;
    var t: stopwatch;
    t.start();
    for i in 1..numOps {
      sum+=libdivide_s64_do(i, denom);
    }
    writeln(sum);
    t.stop();
    writeln("libdivide took: ", t.elapsed());
  }
}

proc runChapelDiv() {
  for j in 1..trials {
    var sum = 0;
    var t: stopwatch;
    t.start();

    for i in 1..numOps {
      sum += (i/10);
    }
    writeln(sum);
    t.stop();
    writeln("regular divide took: ", t.elapsed());
  }
}
