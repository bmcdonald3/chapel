require '../lib/ArrowAll.chpl';
use ArrowAll as Arrow;
use BlockDist;

proc main() {
  var (sizes, ty) = getArrSizeAndType(["test.parquet", "test2.parquet"], 0);

  var A = newBlockArr(0..#(+ reduce sizes), int);

  readFiles(A, ["test.parquet", "test2.parquet"]);
  writeln(A);
}
