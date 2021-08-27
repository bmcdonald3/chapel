require '../lib/ArrowAll.chpl';
use ArrowAll as Arrow;

proc main() {
  var toParquet = [i in 0..#10] i;
  var table = new arrowTable(new arrowRecordBatch("col1", new arrowArray(toParquet)));
 Arrow.writeTableToParquetFile(table, "test.parquet");

 var pqReader = new parquetFileNonPersistent("test.parquet");
 var fromParquet = pqReader.readColumn(0);
 writeln(toParquet);
 writeln(fromParquet);
}
 