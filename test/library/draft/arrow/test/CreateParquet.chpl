require '../lib/ArrowAll.chpl';
use ArrowAll as Arrow;

proc main() {
  var toParquet = [i in 0..#10] i;
  var table = new arrowTable(new arrowRecordBatch("col1", new arrowArray(toParquet), "col2", new arrowArray(toParquet)));
  Arrow.writeTableToParquetFile(table, "test.parquet");

  var pqReader = new parquetFileReader("test.parquet");
  var fromParquet = pqReader.readColumn(1);
  writeln(toParquet);
  writeln(fromParquet);

  var asd = new parquetFileWriter("test2.parquet");
  asd.addColumn(toParquet, 0, "first-col");
  asd.addColumn(toParquet, 1, "second-col");
  asd.finish();

  var pqReader2 = new parquetFileReader("test2.parquet");
  var fromParquet2 = pqReader2.readColumn(1);
  writeln(toParquet);
  writeln(fromParquet2);
}
