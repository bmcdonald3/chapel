use BigInteger;
use Time;

config const numOps = 100000000;

var a: bigint = new bigint(1000);

var c: uint;

var t: stopwatch;

t.start();
for i in 0..#numOps {
  c = a.size();
}
t.stop();

writeln("Took: ", t.elapsed());
