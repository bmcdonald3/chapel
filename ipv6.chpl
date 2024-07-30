use BlockDist;
use Time;

config const SIZE=100;

proc main() {
  var t1: stopwatch;
  var t2: stopwatch;
  t1.start();
  var recArr = blockDist.createArray(0..#SIZE, i128);
  t1.stop();
  writeln(t1.elapsed());

  t2.start();
  var uintArr1 = blockDist.createArray(0..#SIZE, uint);
  var uintArr2 = blockDist.createArray(0..#SIZE, uint);
  t2.stop();
  writeln(t2.elapsed());
}

record i128 {
  var low: uint;
  var high: uint;
  proc init() {}
  proc init(a,b) {
    low = a;
    high = b;
  }
}
operator i128.+(a,b) {
  var ret = new i128(0,0);
  ret.low = (a.low + b.low);
  ret.high = (b.high + a.high);
  return ret;
}


