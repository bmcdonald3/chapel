module IntParquet {
  require "Arrow.chpl";
  require "-larrow-glib", "-lglib-2.0", "-lgobject-2.0";
  use Arrow;
  use CPtr;
  use parquetHeaders;

  proc main() {
    var arr: arrowArray = new arrowArray([25,26,27,28,29]);
    var rb = new arrowRecordBatch("first", arr);
    var table = new arrowTable(rb); 
    Arrow.writeTableToParquetFile(table, "introw.parquet");
    var t = Arrow.readParquetFileToTable("introw.parquet");
    var err: GErrorPtr;


    var chunk = garrow_table_get_column_data(t.tbl, 0);
    writeln(garrow_chunked_array_get_length(chunk));

    var len = garrow_chunked_array_get_length(chunk);
    var loc = garrow_chunked_array_get_chunk(chunk, 0:guint):c_ptr(GArrowInt64Array);

    
    var readArr = Arrow.readParquetFileToArr("introw.parquet");
    writeln(readArr);

    // Doesn't work yet, need to convert from char* to
    // Chapel string
    //var strArr = Arrow.readParquetFileToStringArr("introw.parquet");

    var rb2 = new arrowRecordBatch("first", arr, "second", new arrowArray([9,8,7,6,5]));
    Arrow.writeTableToParquetFile(new arrowTable(rb2), "introws.parquet");
    
    var asd = readParquetFileToArrs("introws.parquet");
    writeln(asd);

    var column = readParquetFileColumn("introws.parquet", 1);
    writeln(column);
    column = readParquetFileColumn("introws.parquet", 0);
    writeln(column);
  }
}
