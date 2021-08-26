use Arrow;
use parquetHeaders;
use CPtr;

proc main() {
  var f = new parquetFile("big-parquet.parquet");
  f.writeSchema();
}
