require '../lib/ArrowAll.chpl';
use ArrowAll as Arrow;

proc main() {
  var toParquet = [i in 0..#10] "a" + i:string;
  var table = new arrowTable(new arrowRecordBatch("col1", new arrowArray(toParquet)));
  Arrow.writeTableToParquetFile(table, "stringtest.parquet");

  var pqReader = new parquetFileNonPersistent("stringtest.parquet");
  var fromParquet = pqReader.readColumnStr(0);
  writeln(toParquet);
  writeln(fromParquet);
}
