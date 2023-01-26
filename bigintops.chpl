use BigInteger, Time, List;

config param perfTest = true;

config const numOps = 10;

proc main() {
  runOnStmtTest(1:bigint);
}

proc runOnStmtTest(inputVal: bigint) {
  var a: bigint = inputVal;
  var b: bigint = 0;

  var t: stopwatch;
  if perfTest then t.start();

  for i in 1..numOps {
    b = 0;
    b.pow(a, 2:uint);
  }

  if perfTest {
    t.stop();
    writeln("Elapsed ", inputVal.sizeInBase(2), " on stmt time = ", t.elapsed(TimeUnits.seconds));
  } else {
    writeln("Result: ", b);
  }
}
