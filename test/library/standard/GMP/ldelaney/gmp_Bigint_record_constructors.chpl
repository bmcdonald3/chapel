use BigInteger, IO;

proc main(){
  var x1          = new bigint();
  var x3          = new bigint(100);
  var x4          = new bigint("1100101", 2);
  var x5          = new bigint(x4);
  var x6 : bigint = x5;
  var x7          = x3;

  writeln(x1);

  writeln(x3);

  writeln(x4);

  writeln(x5);

  writeln(x6);

  writeln(x7);
}
