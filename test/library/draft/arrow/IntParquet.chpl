module IntParquet {
  require "Arrow.chpl";
  require "-larrow-glib", "-lglib-2.0", "-lgobject-2.0";
  use Arrow;
  use CPtr;
  use parquetHeaders;

  proc main() {
    var arr: ArrowArray = new ArrowArray([25,26,27,28,29]);
    var rb = new ArrowRecordBatch("first", arr);

    var table = new ArrowTable(rb);
    
    Arrow.writeTableToParquetFile(table, "introw.parquet");

    var t = Arrow.readParquetFileToTable("introw.parquet");

    for i in 0..3 do
      writeln(garrow_int64_array_get_value(arr.val:c_ptr(GArrowInt64Array), i));

    var err: GErrorPtr;
    var chunk = garrow_table_get_column_data(t.tbl, 0);
    writeln(garrow_chunked_array_get_length(chunk));
    
    for i in 0..#garrow_chunked_array_get_length(chunk) { // TODO: put the gets in here so we can have more than 1
    }

    var len = garrow_chunked_array_get_length(chunk);
    var loc = garrow_chunked_array_get_chunk(chunk, 0:guint):c_ptr(GArrowInt64Array);
    var chplArr: [0..#len] int;
    for i in 0..#len do
      chplArr[i] = garrow_int64_array_get_value(loc, i);

    writeln(chplArr);

    var readArr = Arrow.readParquetFileToArr("introw.parquet");
    writeln(readArr);
  }
}
