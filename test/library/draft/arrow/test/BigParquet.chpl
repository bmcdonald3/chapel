require "../lib/ArrowAll.chpl";
use ArrowAll as Arrow;
use CPtr;
use Time;

config const SIZE=1_000_000;;

proc main() {
  createFile();

  var table = read("big-parquet.parquet");
  var t1: Timer;
  t1.start();
  var asd = getParquetColumn(table, 0, int);
  writeln("int one took:", t1.elapsed());
  writeln("last 10 elems: ", asd[SIZE-10..SIZE-1]);

  var t: Timer;
  t.start();
  var strAsd = getParquetColumn(table, 1, string);
  writeln("string one took:", t.elapsed());
  writeln("last 10 elems: ", strAsd[SIZE-10..SIZE-1]);
}

proc createFile() {
  var arr = [i in 0..#SIZE] i;
  var strArr = [i in 0..#SIZE] "asd";

  var arrowArr = new arrowArray(arr);
  var arrowStrArr = new arrowArray(strArr);
  var table = new arrowTable(new arrowRecordBatch("first", arrowArr, "second", arrowStrArr));
  var t: Timer;
  t.start();
  Arrow.writeTableToParquetFile(table, "big-parquet.parquet");
  writeln("write to table took ", t.elapsed());
}
