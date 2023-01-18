use BigInteger;
use BlockDist;
use Time;

config const numOps = 100000000;

var t: stopwatch;

var bArr = newBlockArr({0..1}, bigint);

var c = new bigint(0);

t.start();
for i in 1..numOps do
  c = bArr[0] + bArr[1];
t.stop();

writeln("Addition took                : ",
        t.elapsed());
t.clear();

t.start();
for i in 1..numOps do
  c = bArr[0].myAdd(bArr[1]);
t.stop();

writeln("Addition with primitive took : ",
        t.elapsed());
t.clear();

writeln("First elem locale: ", bArr[0].locale, " Second elem locale: ", bArr[1].locale);
