use BigInteger, Time, BlockDist;

config const numOps = 100000000;
config const dist = false;

var t: stopwatch;
var c: bigint;

if !dist {
  var a = new bigint(100);
  var b = new bigint(200);

  t.start();
  for i in 1..numOps do
    c = a + b;
  t.stop();
} else {
  var arr = newBlockArr({0..1}, bigint);

  t.start();
  for i in 1..numOps do
    c = arr[0] + arr[1];
  t.stop();
}

writeln("Time to run ", numOps, " bigint + :", t.elapsed());
writeln("Distributed = ", dist);
