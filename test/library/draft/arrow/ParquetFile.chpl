use Arrow;
use parquetHeaders;
use CPtr;
use Time;

config const SIZE = 10_000;

proc main() {
  createFile();

  var t1: Timer;
  t1.start();
  var fN = new parquetFileNonPersistent("test.parquet");
  for i in 0..#10 do
    writeln(fN.readColumn(i)[10..19]);
  var done = t1.elapsed();
  writeln("column by column read ", done);

  var fN1 = new parquetFileNonPersistent("test.parquet");
  writeln(fN1.readColumn(0)[10..19]);
  writeln("single column took ", t1.elapsed()-done);
  
  var t:Timer;
  t.start();
  var f = new parquetFile("test.parquet");
  for i in 0..#10 do
    writeln(f.readColumn(i)[10..19]);
  var d = t.elapsed();
  writeln("in memory, whole table read ", d);

  var f1 = new parquetFile("test.parquet");
  writeln(f1.readColumn(0)[10..19]);
  writeln("single column took ", t.elapsed()-d);
}

proc createFile() {
  var arr = [i in 0..#SIZE] i;
  var strArr = [i in 0..#SIZE] "asd";

  var arrowArr = new arrowArray(arr);
  var arrowStrArr = new arrowArray(strArr);
  var table = new arrowTable(new arrowRecordBatch("1", arrowArr,"2", arrowArr,"3", arrowArr,"4", arrowArr,"5", arrowArr,"6", arrowArr,"7", arrowArr,"8", arrowArr,"9", arrowArr,"10", arrowArr));

  Arrow.writeTableToParquetFile(table, "test.parquet");
}
