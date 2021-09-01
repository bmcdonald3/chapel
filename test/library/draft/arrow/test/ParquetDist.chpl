require '../lib/ArrowAll.chpl';
use ArrowAll as Arrow;
use BlockDist;

proc main() {
  var A = newBlockArr(0..9, int);
  readFiles(A, ["test.parquet","test.parquet"]);
}
