module Arrow {
  // require "ArrowDecl.chpl";
  // public use ArrowDecl;
  require "parquetHeaders.chpl";
  use parquetHeaders;
  public use SysCTypes, CPtr;
  
  // Temporary Error caller for convenience.
  inline proc printGError(msg: string, error: GErrorPtr){
    g_print("%s %s\n".c_str(): c_ptr(gchar), msg.c_str(), error.deref().message);
    g_error_free(error);
  }

  // -------------------------- Type Declarations and Functions -------------

  record arrowArray{
    var val: c_ptr(GArrowArray);

    proc init(arr: [] ?arrayType, validIndices: [] int = [-1], 
                invalidIndices: [] int = [-1]){
      this.val = array(arr, validIndices, invalidIndices);
    }

  }

  proc arrowInt32(): GArrowInt32DataType {
    return garrow_int32_data_type_new();
  }

  proc arrowInt64(): GArrowInt32DataType {
    return garrow_int64_data_type_new();
  }
  proc arrowString(): GArrowStringDataType {
    return garrow_string_data_type_new();
  }
  proc arrowBool(): GArrowBooleanDataType {
    return garrow_boolean_data_type_new();
  }
  //--------------------------- Array building functions --------------------
  
  proc array(arr: [] ?arrayType, validIndices: [] int = [-1], 
              invalidIndices: [] int = [-1]): c_ptr(GArrowArray) {
    // Build full validity array here since each function needs it anyways
    var validityArr: [0..#arr.size] gboolean;
    if(validIndices[0] != -1 && invalidIndices[0] != -1){
      // Both valid indices and invalid indices was passed which is not good
      // Maybe raise a compilerError here instead of the normal error handling
      writeln("Only one of two possible validity arguments may be passed.\
      [both validIndices and invalidIndices were passed]");
      var fakeReturn: c_ptr(GArrowArray);
      return fakeReturn;
    } else if(validIndices[0] != -1){
      validityArr = [i in 0..#arr.size] 0: gboolean;
      forall i in 0..#validIndices.size {
        validityArr[validIndices[i]] = 1: gboolean;
      }
    } else if(invalidIndices[0] != -1){
      validityArr = [i in 0..#arr.size] 1: gboolean;
      forall i in 0..#invalidIndices.size {
        validityArr[invalidIndices[i]] = 0: gboolean;
      }
    } else {
      validityArr = [i in 0..#arr.size] 1: gboolean;
    }
    select arrayType {
      when int do return int64Array(arr, validityArr) : c_ptr(GArrowArray);
      when string do return stringArray(arr, validityArr) : c_ptr(GArrowArray);
      when bool do return boolArray(arr, validityArr) : c_ptr(GArrowArray);
      otherwise {
        writeln("Unsupported type, \nreturning nil"); 
        var fakeReturn: c_ptr(GArrowArray);
        return fakeReturn;
      }
    }
  }

  proc int64Array(arr: [] int, validity: [] gboolean) : c_ptr(GArrowInt64Array) {
    var success: gboolean = 1;
    var error: GErrorPtr;
    var builder: c_ptr(GArrowInt64ArrayBuilder) = garrow_int64_array_builder_new();
    var retval: c_ptr(GArrowInt64Array);
    if (success) {
      var intArrLen: gint64 = arr.size;
      var intValArr = [val in arr] val;
      var intValidityArrLen = intArrLen;
      success = garrow_int64_array_builder_append_values(
          builder, c_ptrTo(intValArr), intArrLen, c_ptrTo(validity), intValidityArrLen, c_ptrTo(error));
    }
    if (!success) {
      printGError("failed to append:", error);
      g_object_unref(builder);
      return retval;
    }
    retval = garrow_array_builder_finish(
      GARROW_ARRAY_BUILDER(builder), c_ptrTo(error)) : c_ptr(GArrowInt64Array);
    if (isNull(retval)) {
      printGError("failed to finish:", error);
      g_object_unref(builder);
      return retval;
    }
    g_object_unref(builder);

    return retval;
  }
  proc int32Array(arr: [] int(32), validity: [] gboolean) : c_ptr(GArrowInt32Array) {
    var success: gboolean = 1;
    var error: GErrorPtr;
    var builder: c_ptr(GArrowInt32ArrayBuilder) = garrow_int32_array_builder_new();
    var retval: c_ptr(GArrowInt32Array);
    if (success) {
      var intArrLen: gint64 = arr.size;
      var intValArr = [val in arr] val: gint32;
      var intValidityArrLen: gint64 = intArrLen;
      success = garrow_int32_array_builder_append_values(
          builder, c_ptrTo(intValArr), intArrLen, c_ptrTo(validity), intValidityArrLen, c_ptrTo(error));
    }
    if (!success) {
      printGError("failed to append:", error);
      g_object_unref(builder);
      return retval;
    }
    retval = garrow_array_builder_finish(
      GARROW_ARRAY_BUILDER(builder), c_ptrTo(error)) : c_ptr(GArrowInt32Array);
    if (isNull(retval)) {
      printGError("failed to finish:", error);
      g_object_unref(builder);
      return retval;
    }
    g_object_unref(builder); 

    return retval;
  }
  proc stringArray(arr: [] string, validity: [] gboolean) : c_ptr(GArrowStringArray) {
    var success: gboolean = 1;
    var error: GErrorPtr;
    var builder: c_ptr(GArrowStringArrayBuilder) = garrow_string_array_builder_new();
    var retval: c_ptr(GArrowStringArray);
    if (success) {
      var strArrLen: gint64 = arr.size: gint64;
      var strValArr = [val in arr] val.c_str() : c_ptr(gchar);
      var strValidityArrLen: gint64 = strArrLen;
      success = garrow_string_array_builder_append_strings(
          builder, c_ptrTo(strValArr), strArrLen, c_ptrTo(validity), strValidityArrLen, c_ptrTo(error));
    }
    if (!success) {
      printGError("failed to append:", error);
      g_object_unref(builder);
      return retval;
    }
    retval = garrow_array_builder_finish(
      GARROW_ARRAY_BUILDER(builder), c_ptrTo(error)) : c_ptr(GArrowStringArray);
    if (isNull(retval)) {
      printGError("failed to finish:", error);
      g_object_unref(builder);
      return retval;
    }
    g_object_unref(builder); 

    return retval;
  }

  proc boolArray(arr: [] bool, validity: [] gboolean) : c_ptr(GArrowBooleanArray) {
    var success: gboolean = 1;
    var error: GErrorPtr;
    var builder: c_ptr(GArrowBooleanArrayBuilder) = garrow_boolean_array_builder_new();
    var retval: c_ptr(GArrowBooleanArray);
    if (success) {

      var boolArrLen: gint64 = arr.size: gint64;
      var boolValArr = [val in arr] val: gboolean;
      var boolValidityArrLen: gint64 = boolArrLen;
      success = garrow_boolean_array_builder_append_values(
          builder, c_ptrTo(boolValArr), boolArrLen, c_ptrTo(validity), boolValidityArrLen, c_ptrTo(error));
    }
    if (!success) {
      printGError("failed to append:", error);
      g_object_unref(builder);
      return retval;
    }
    retval = garrow_array_builder_finish(
      GARROW_ARRAY_BUILDER(builder), c_ptrTo(error)) : c_ptr(GArrowBooleanArray);
    if (isNull(retval)) {
      printGError("failed to finish:", error);
      g_object_unref(builder);
      return retval;
    }
    g_object_unref(builder); 

    return retval;
  }

  // ---------------------- Record Batches and schemas ----------------------

  record arrowRecordBatch {
    var rcbatch: c_ptr(GArrowRecordBatch);

    proc init(args ...?n){
      this.rcbatch = recordBatch( (...args) ); // Unpacking the tuple using ...
    }

  }
  proc recordBatch (args ...?n): c_ptr(GArrowRecordBatch) {
    
    // Verifying the Integrity of the arguments
    if(n%2!=0) then
      compilerError("Mismatched arguments");
    for param i in 0..#n {
      if i%2 == 0 {
        if args[i].type != string then
          compilerError("Wrong even argument type");
      } else {
        if args[i].type != arrowArray then
          compilerError("Wrong odd argument type");
      }
    }

    var fields: c_ptr(GList) = nil;
    for param i in 1..n by 2{
      // Building the (column)
      var col: c_ptr(GArrowField) = garrow_field_new(
                              args[i-1].c_str(): c_ptr(gchar), 
                              garrow_array_get_value_data_type(args[i].val: c_ptr(GArrowArray)));

      // Adding the column to the list
      fields = g_list_append(fields, col);

      // Moving on the the next pair of arguments
    }

    // Gotta build this schema now
    var schema: c_ptr(GArrowSchema) = garrow_schema_new(fields);

    // We might want to check the equality of the arrays length but the error will give it to us
    // anyway if they are not equal
    var n_rows: guint32 = garrow_array_get_length(args[1].val): guint32;

    var arrays: c_ptr(GList) = nil;
    for param j in 1..n by 2 {
      // Adding the array to the list
      arrays = g_list_append(arrays, args[j].val);
    }

    var error: GErrorPtr;
    var record_batch: c_ptr(GArrowRecordBatch) = garrow_record_batch_new(schema, n_rows, arrays, c_ptrTo(error));
    if(isNull(record_batch)){
      g_print("%s\n".c_str(): c_ptr(gchar), error.deref().message);
    }
    // And after a lot of lines of code we have created the record batch.
    // The last part can also be done using a record batch builder class.
    //print_record_batch(record_batch);
    return record_batch;
  }

  record arrowTable {
    var tbl: c_ptr(GArrowTable);
  
    proc init(args: arrowRecordBatch ...?n){
      this.tbl = table( (...args) ); // Unpacking the tuple using ...
    }

    proc init(recordBatches: [] arrowRecordBatch){
      this.tbl = table(recordBatches);
    }

    proc init(table: c_ptr(GArrowTable)){
      this.tbl = table;
    }

  }
  proc table(recordBatches: [] arrowRecordBatch): c_ptr(GArrowTable) {
    var error: GErrorPtr;
    var schema: c_ptr(GArrowSchema) = garrow_record_batch_get_schema(recordBatches[0].rcbatch);
    var rbArray = [rb in recordBatches] rb.rcbatch;
    var retval: c_ptr(GArrowTable) = garrow_table_new_record_batches(
      schema, c_ptrTo(rbArray), recordBatches.size : guint64, c_ptrTo(error));
    
    if(isNull(retval)){
      g_print("Error creating table: %s\n", error.deref().message);
    }
    return retval;
  }

  proc table(recordBatches: arrowRecordBatch ...?n){
    var error: GErrorPtr;
    var schema: c_ptr(GArrowSchema) = garrow_record_batch_get_schema(recordBatches[0].rcbatch: c_ptr(GArrowRecordBatch));
    var rbArray = [rb in recordBatches] rb.rcbatch;
    var retval: c_ptr(GArrowTable) = garrow_table_new_record_batches(
      schema, c_ptrTo(rbArray), recordBatches.size : guint64, c_ptrTo(error));
    
    if(isNull(retval)){
      printGError("Error creating table:", error);
    }
    return retval;
  }


  // -------------------------- Parquet -------------------------------------

  proc getSingleSchemaType(schema, idx: int) {
    var field = garrow_schema_get_field(schema, idx:guint);
    var id = garrow_data_type_get_id(garrow_field_get_data_type(field));
    if id == 13 then return "string";
    else return "int";
  }
  
  record parquetFile {
    var table: c_ptr(GArrowTable);
    var schema: c_ptr(GArrowSchema);

    proc init(path: string) {
      var error: GErrorPtr;
      var pqFileReader = gparquet_arrow_file_reader_new_path(path.c_str(): c_ptr(gchar), c_ptrTo(error));
      if isNull(pqFileReader) {
        printGError("failed to open file: ", error);
        exit(EXIT_FAILURE);
      }
      table = gparquet_arrow_file_reader_read_table(pqFileReader, c_ptrTo(error));
      if isNull(table) {
        printGError("failed to read table: ", error);
        exit(EXIT_FAILURE);
      }
      schema = gparquet_arrow_file_reader_get_schema(pqFileReader, c_ptrTo(error));
    }

    proc readColumnByIndex(idx: int) {
      /*var iarr = [1,2,3];
      var sarr = ["a", "s", "d"];
      if types[0] == 0 then return iarr;
      else return sarr;*/
    }

    proc readColumn(col: int) //where getSingleSchemaType(schema, col) == "int" {
    {
      var chunk = garrow_table_get_column_data(table, col:gint);
      var len = garrow_chunked_array_get_n_rows(chunk);
      var ret: [0..#len] int;

      var loc = garrow_chunked_array_get_chunk(chunk, 0:guint):c_ptr(GArrowInt64Array);
      forall i in 0..#len {
        ret[i] = garrow_int64_array_get_value(loc, i);
      }
      return ret;
    }

    proc readColumnStr(col: int) //where getSingleSchemaType(schema, col) == "string" {
    {
      extern proc strlen(str): int;
      var chunk = garrow_table_get_column_data(table, col:gint);
      var len = garrow_chunked_array_get_n_rows(chunk);
      var ret: [0..#len] string;
      
      var loc = garrow_chunked_array_get_chunk(chunk, 0:guint):c_ptr(GArrowStringArray);
      forall i in 0..#len {
        var gstr = garrow_string_array_get_string(loc, i);
        ret[i] = try! createStringWithNewBuffer(gstr:c_string, length=strlen(gstr));
      }
      return ret;
    }

    proc writeSchema() {
      extern proc strlen(str): int;
      var gstr = garrow_schema_to_string(schema);
      var sch = try! createStringWithNewBuffer(gstr:c_string, length=strlen(gstr));
      writeln(sch);
    }
  }

  record parquetFileNonPersistent {
    var path: string;
    var pqFileReader: c_ptr(GParquetArrowFileReader);
    var schema: c_ptr(GArrowSchema);

    proc init(path: string) {
      this.path = path;
      var error: GErrorPtr;
      pqFileReader = gparquet_arrow_file_reader_new_path(path.c_str(): c_ptr(gchar), c_ptrTo(error));
      if isNull(pqFileReader) {
        printGError("failed to open file: ", error);
        exit(EXIT_FAILURE);
      }
      schema = gparquet_arrow_file_reader_get_schema(pqFileReader, c_ptrTo(error));
    }

    proc readColumnByIndex(idx: int) {
      /*var iarr = [1,2,3];
      var sarr = ["a", "s", "d"];
      if types[0] == 0 then return iarr;
      else return sarr;*/
    }

    proc readColumn(col: int) //where getSingleSchemaType(schema, col) == "int" {
    {
      var error: GErrorPtr;
      var chunk = gparquet_arrow_file_reader_read_column_data(pqFileReader, col: gint, c_ptrTo(error));
      var len = garrow_chunked_array_get_n_rows(chunk);
      var ret: [0..#len] int;

      var loc = garrow_chunked_array_get_chunk(chunk, 0:guint):c_ptr(GArrowInt64Array);
      forall i in 0..#len {
        ret[i] = garrow_int64_array_get_value(loc, i);
      }
      return ret;
    }

    proc readColumnStr(col: int) //where getSingleSchemaType(schema, col) == "string" {
    {
      var error: GErrorPtr;
      extern proc strlen(str): int;
      var chunk = gparquet_arrow_file_reader_read_column_data(pqFileReader, col: gint, c_ptrTo(error));
      var len = garrow_chunked_array_get_n_rows(chunk);
      var ret: [0..#len] string;
      
      var loc = garrow_chunked_array_get_chunk(chunk, 0:guint):c_ptr(GArrowStringArray);
      forall i in 0..#len {
        var gstr = garrow_string_array_get_string(loc, i);
        ret[i] = try! createStringWithNewBuffer(gstr:c_string, length=strlen(gstr));
      }
      return ret;
    }

    proc writeSchema() {
      extern proc strlen(str): int;
      var gstr = garrow_schema_to_string(schema);
      var sch = try! createStringWithNewBuffer(gstr:c_string, length=strlen(gstr));
      writeln(sch);
    }
  }
  
  proc writeTableToParquetFile(table: arrowTable, path: string) {
    var error: GErrorPtr;
    var writer_properties: c_ptr(GParquetWriterProperties) = gparquet_writer_properties_new();
    var writer: c_ptr(GParquetArrowFileWriter) = gparquet_arrow_file_writer_new_path(
                                                  garrow_table_get_schema(table.tbl),
                                                  path.c_str(): c_ptr(gchar), 
                                                  writer_properties,
                                                  c_ptrTo(error));
    if(isNull(writer)){
      printGError("failed to initialize writer:", error);
      exit(EXIT_FAILURE);
    }
    var success: gboolean = gparquet_arrow_file_writer_write_table(writer,
                                                      table.tbl ,
                                                      10 : guint64, // Should not be hardcoded
                                                      c_ptrTo(error));
    if(!success){
      printGError("failed to write table:", error);
      exit(EXIT_FAILURE);
    }

    success = gparquet_arrow_file_writer_close(writer, c_ptrTo(error));

    if(!success){
      printGError("could not close writer:", error);
      exit(EXIT_FAILURE);
    }
  }

  proc readParquetFileToTable(path: string): arrowTable {
    var error: GErrorPtr;
    var pqFileReader: c_ptr(GParquetArrowFileReader) = gparquet_arrow_file_reader_new_path(
      path.c_str(): c_ptr(gchar), c_ptrTo(error));

    if(isNull(pqFileReader)){
      printGError("failed to open the file:", error);
      exit(EXIT_FAILURE);
    }

    // Reading the whole table
    var table: c_ptr(GArrowTable) = gparquet_arrow_file_reader_read_table(pqFileReader, c_ptrTo(error));
    if(isNull(table)){
      printGError("failed to read the table:", error);
      exit(EXIT_FAILURE);
    }
    var retval = new arrowTable(table);
    return retval;
  }

  proc read(path: string) {
    var error: GErrorPtr;
    var pqFileReader: c_ptr(GParquetArrowFileReader) = gparquet_arrow_file_reader_new_path(
      path.c_str(): c_ptr(gchar), c_ptrTo(error));

    if(isNull(pqFileReader)){
      printGError("failed to open the file:", error);
      exit(EXIT_FAILURE);
    }

    // Reading the whole table
    var table: c_ptr(GArrowTable) = gparquet_arrow_file_reader_read_table(pqFileReader, c_ptrTo(error));
    if(isNull(table)){
      printGError("failed to read the table:", error);
      exit(EXIT_FAILURE);
    }
    return table;
  }
  
  proc readParquetFileToArr(path: string) {
    var table = read(path);

    // get values to change to Chapel array
    var chunk = garrow_table_get_column_data(table, 0);
    var len = garrow_chunked_array_get_n_rows(chunk);
    
    var loc = garrow_chunked_array_get_chunk(chunk, 0:guint):c_ptr(GArrowInt64Array);
    var ret: [0..#len] int;
    forall i in 0..#len do
      ret[i] = garrow_int64_array_get_value(loc, i);
    
    return ret;
  }

  proc readParquetFileToArrs(path: string) {
    var table = read(path);

    var ret: [0..#garrow_table_get_n_columns(table)] [0..#garrow_table_get_n_rows(table)] int;
    
    // get values to change to Chapel array
    for col in 0..#garrow_table_get_n_columns(table) {
      var chunk = garrow_table_get_column_data(table, col);
      var len = garrow_chunked_array_get_n_rows(chunk);

      var localChunk = garrow_chunked_array_get_chunk(chunk, 0:guint):c_ptr(GArrowInt64Array);
      var loc: [0..#len] int;
      for i in 0..#len do
        loc[i] = garrow_int64_array_get_value(localChunk, i);
      ret[col] = loc;
    }
    
    return ret;
  }

  proc readParquetFileColumn(path: string, col: int) {
    var table = read(path);

    // get values to change to Chapel array
    var chunk = garrow_table_get_column_data(table, col:gint);
    var len = garrow_chunked_array_get_n_rows(chunk);
    var ret: [0..#len] int;

    var localChunk = garrow_chunked_array_get_chunk(chunk, 0:gint):c_ptr(GArrowInt64Array);
    
    for i in 0..#len do
      ret[i] = garrow_int64_array_get_value(localChunk, i);
    
    return ret;
  }

  proc readParquetColumnToStringArr(path: string, col: int) {
    extern proc strlen(str): int;
    var table = read(path);

    // get values to change to Chapel array
    var chunk = garrow_table_get_column_data(table, col:gint);
    var len = garrow_chunked_array_get_n_rows(chunk);
    
    var loc = garrow_chunked_array_get_chunk(chunk, 0:guint):c_ptr(GArrowStringArray);

    var ret: [0..#len] string;
    for i in 0..#len {
      var gstr = garrow_string_array_get_string(loc, i);
      ret[i] = try! createStringWithNewBuffer(gstr:c_string, length=strlen(gstr));
    }

    return ret;
  }

  proc getIntColumn(path: string, col: int) {
    use Time;
    var table = read(path);
    var typeVal = getColumnType(table, col);
    var chunk = garrow_table_get_column_data(table, col:gint);
    var len = garrow_chunked_array_get_n_rows(chunk);
    var ret: [0..#len] int;
    if typeVal == 9 {
      var loc = garrow_chunked_array_get_chunk(chunk, 0:guint):c_ptr(GArrowInt64Array);
      var t: Timer;
      t.start();
      forall i in 0..#len {
        ret[i] = garrow_int64_array_get_value(loc, i);
      }
      writeln("copy took:", t.elapsed());
    } else if typeVal == 13 {
      writeln("error, this is a string column");
    }
    return ret;
  }

  // eltType == 0 is int, 1 is string
  proc getParquetColumn(table, col: int, type eltType=int) {
    var chunk = garrow_table_get_column_data(table, col:gint);
    var len = garrow_chunked_array_get_n_rows(chunk);
    var ret: [0..#len] eltType;    
    if eltType==int {
      var loc = garrow_chunked_array_get_chunk(chunk, 0:guint):c_ptr(GArrowInt64Array);
      forall i in 0..#len {
        ret[i] = garrow_int64_array_get_value(loc, i);
      }
    } else if eltType==string {
      extern proc strlen(str): int;
      var ret: [0..#len] string;
      var loc = garrow_chunked_array_get_chunk(chunk, 0:guint):c_ptr(GArrowStringArray);
      forall i in 0..#len {
        var gstr = garrow_string_array_get_string(loc, i);
        ret[i] = try! createStringWithNewBuffer(gstr:c_string, length=strlen(gstr));
      }
    }
    return ret;
  }

  proc getColumnType(table, col: int) {
    var chunk = garrow_table_get_column_data(table, col:gint);
    return garrow_chunked_array_get_value_type(chunk);
  }

  //----------------------- Functions for printing ----------------------------
  proc printArray(arr: arrowArray) {
    printArray(arr.val);
  }
  proc printArray(array: c_ptr(GArrowArray)) {
    var error: GErrorPtr;
    var str: c_ptr(gchar) = garrow_array_to_string(array, c_ptrTo(error));
    if(isNull(str)){
      g_print("Failed to print: %s\n".c_str(): c_ptr(gchar), error.deref().message);
      g_error_free(error);
      return;
    }
    g_print("%s\n".c_str(): c_ptr(gchar),str);
  }

  proc printRecordBatch(recordBatch: arrowRecordBatch){
    printRecordBatch(recordBatch.rcbatch);
  }
  proc printRecordBatch(recordBatch: c_ptr(GArrowRecordBatch)) {
    var error: GErrorPtr;
    var str: c_ptr(gchar) = garrow_record_batch_to_string(recordBatch, c_ptrTo(error));
    if(isNull(str)){
      g_print("Failed to print: %s\n".c_str(): c_ptr(gchar), error.deref().message);
      g_error_free(error);
      return;
    }
    g_print("%s\n".c_str(): c_ptr(gchar),str: c_ptr(gchar));
  }

  proc printTable(table: arrowTable) {
    printTable(table.tbl);
  }
  proc printTable(table: c_ptr(GArrowTable)) {
    if(isNull(table)) then return;
    var error: GErrorPtr;
    var str: c_ptr(gchar) = garrow_table_to_string(table, c_ptrTo(error));
    if(isNull(str)){
      g_print("Failed to print: %s\n".c_str(): c_ptr(gchar), error.deref().message);
      g_error_free(error);
      return;
    }
    g_print("%s\n".c_str(): c_ptr(gchar),str: c_ptr(gchar));
  }
}
