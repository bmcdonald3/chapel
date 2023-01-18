use BigInteger;
use Time;

config const numOps = 100000000;

var t: stopwatch;

var a = new bigint(50);
var b = new bigint(100);
var c = new bigint(0);

t.start();
for i in 1..numOps do
  c = a + b;
t.stop();

writeln("Addition took                : ",
        t.elapsed());
t.clear();

t.start();
for i in 1..numOps do
  c = a.myAdd(b);
t.stop();

writeln("Addition with primitive took : ",
        t.elapsed());
