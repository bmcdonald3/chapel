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
  fN.writeSchema();
  for i in 0..#10 do
    writeln(fN.readColumn(i)[10..19]);
  writeln("column by column read ", t1.elapsed());
  
  var t:Timer;
  t.start();
  var f = new parquetFile("test.parquet");
  f.writeSchema();
  for i in 0..#10 do
    writeln(f.readColumn(i)[10..19]);
  writeln("in memory, whole table read ", t.elapsed());
}

proc createFile() {
  var arr = [i in 0..#SIZE] i;
  var strArr = [i in 0..#SIZE] "asd";

  var arrowArr = new arrowArray(arr);
  var arrowStrArr = new arrowArray(strArr);
  var table = new arrowTable(new arrowRecordBatch("1", arrowArr,"2", arrowArr,"3", arrowArr,"4", arrowArr,"5", arrowArr,"6", arrowArr,"7", arrowArr,"8", arrowArr,"9", arrowArr,"10", arrowArr));

  Arrow.writeTableToParquetFile(table, "test.parquet");
}
