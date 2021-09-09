require '../lib/ArrowAll.chpl';
use ArrowAll as Arrow;
use BlockDist;

proc main() {
  /*var parquetWriter = new parquetFileWriter("test2.parquet");
  parquetWriter.addColumn(toParquet, 0, "first-int-col");
  parquetWriter.addColumn(arr, 1, "second-int-col");
  parquetWriter.addColumn(strArr, 1, "str-col");
  parquetWriter.finish();*/
  
  var (sizes, ty) = getArrSizeAndType(["test.parquet", "test2.parquet", "test.parquet", "test2.parquet"], 0);

  var A = newBlockArr(0..#(+ reduce sizes), int);

  readFiles(A, ["test.parquet", "test.parquet", "test.parquet", "test2.parquet"], [10,10,10,10]);
  writeln(A);


  var B = newBlockArr(0..#10, int);
  readFileColumnToDist(B, "test.parquet", 0);
  writeln(B);
  for val in B do
    writeln(val.locale);
}
