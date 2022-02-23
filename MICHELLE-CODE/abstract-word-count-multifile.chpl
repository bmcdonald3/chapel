/* abstract-word-count-multifile.chpl

   This example demonstrates how to read in a directory of CSV files and for
   each file do a wordcount for the "abstract" field of all the records in
   the file.

FIXME: parallel?

   To run this example, first make sure you have an installation of the
   Chapel compiler. For instructions on how to do that see
   https://chapel-lang.org/docs/master/usingchapel/building.html

   You can compile and run this example on the command line by doing a
       source util/quickstart/setchplenv.bash
   in the Chapel home directory, and then compiling and running this file 
   as follows:
       chpl abstract-word-count-multifile.chpl
       ./abstract-word-count-multifile

   FIXME: running it on a larger input file using parallelism

FIXME: doing a reduction of the word count?

   The example csv file is from Kaggle,
   https://www.kaggle.com/allen-institute-for-ai/CORD-19-research-challenge?select=metadata.csv
   The included metadata-20lines.csv only has 20 lines of data including the
   header row that has the column names.

  References in the Chapel documentation:
    file readers and writers
      https://chapel-lang.org/docs/main/modules/standard/IO.html#i-o-overview
      https://chapel-lang.org/docs/primers/fileIO.html

    list of files in a directory:
      https://chapel-lang.org/docs/modules/standard/FileSystem.html#FileSystem.findfiles
      example usage: https://github.com/chapel-lang/chapel/blob/main/modules/packages/HDF5.chpl#L3529


    associative arrays: FIXME
parallelism: FIXME
 */
use IO;
use List;
use SortedMap;

config const inputDir = "InputFiles";
config const outputFileName = "abstract-word-count.csv";
config const debug = true;
config const minCount = 10;

// FIXME: some doc cleanup in these three needed
// https://chapel-lang.org/docs/usingchapel/executing.html
// https://chapel-lang.org/docs/language/spec/locales.html?highlight=maxtaskpar#ChapelLocale.locale.maxTaskPar
// https://chapel-lang.org/docs/usingchapel/executing.html#controlling-the-number-of-threads
//writeln("dataParTasksPerLocale=", dataParTasksPerLocale);
writeln("here.maxTaskPar = ", here.maxTaskPar);

//-----------------------------------------------------------------------
// Get a list of .csv filenames from the input directory.
use FileSystem;

use Time;
var t: Timer;
t.start();

var filenames: list(string);

for f in findfiles(inputDir) {
  if f.endsWith(".csv") {
    filenames.append(f);
  }
}
if debug then writeln("filenames = ",filenames);

//-----------------------------------------------------------------------
// Read in the input csv files and at the same time do a wordcount per csv file.

forall file in filenames {
  // Open up the input file.
  var f = open(file, iomode.r);
  writeln("filename = ", file);

  // Create a reader of the input csv file
  var reader = f.reader();

  // Read the first line to get the column names.
  var line : string;
  if (!reader.readline(line)) then
    writeln("ERROR: ", file, " appears to be empty");

  var indexForAbstractColumn = findAbstractColumnIndex(line);
  if debug then writeln("\nindexForAbstractColumn: ", indexForAbstractColumn);

  // declare a Map to maintain the count
  var wordCount = new sortedMap(string,int);

  // Read in all of the lines of the file.
  while (reader.readline(line)) {
    // find the abstract field
    var fieldIndex = 0;
    for fieldText in fieldsInRow(line) {
      if fieldIndex==indexForAbstractColumn {
        // count each time a word appears in the abstract column of this line
        for word in fieldText.split(" ") {
          wordCount[word] += 1;
        }
        break;
      }
      fieldIndex += 1;
    }
  } 

  // filter out any words that do not show up more than once
  var infrequentWords = new list(string);
  for (word,count) in wordCount.items() {
    if count<=minCount then infrequentWords.append(word);
  }
  for word in infrequentWords {
    wordCount.remove(word);
  }

  if debug then writeln("wordCount = ", wordCount);
}

// fieldsInRow is an example of a user-defined iterator.  When called on
// a line from a csv file, it will yield the next column value each time
// it is called in a loop.
// See https://chapel-lang.org/docs/primers/iterators.html for some examples.
iter fieldsInRow(line) {
  var start = 0;
  while start<line.size {
    var (nextVal, nextCommaIdx) = nextField(line, start);
    start = nextCommaIdx + 1; // The next field will start after the comma.
    yield nextVal;
  }
}

// Returns the index of the next comma or the string length if no
// next comma is found.  Commas inside double quoted strings will be ignored.
proc findNextCommaNotInQuotes(str : string, start : int) {
  var inDoubleQuotes = false;
  for i in start..(str.size-1) {
    if !inDoubleQuotes && str[i]==',' then return i;
    if str[i]=='"' then inDoubleQuotes = !inDoubleQuotes;
  }
  return str.size;
}

// Given a line from a csv file and a starting index
// returns a tuple of the string starting at the starting index and
// ending right before the next comma not in a quoted string, and
// the index of the next comma.
//      input: "ab,cd,"ef",f"   and start=3
//      output: "cd"
//
//      input: "ab,cd,"ef",f"   and start=6
//      output: ""ef""
// Assumes that the starting index given is not within a quoted string.
proc nextField(line:string, start:int) {
    var commaIdx = findNextCommaNotInQuotes(line,start);
    var fieldVal = line[start..(commaIdx-1)];
    return (fieldVal.strip(),commaIdx);
}

// Given the string that is the first line of a csv file that has column names
// returns a list of column names in order.
proc createListOfColNames(line : string) {
  var colNames : list(string);
  var start = 0;
  while (start<line.size) {
    var (nextVal,commaIdx) = nextField(line,start);
    colNames.append(nextVal);
    start = commaIdx+1;
  }
  return colNames;
} 

// Given the string that is the first line of a csv file that has column names
// returns the index for the column called "abstract".
// Returns -1 if it doesn't find that column.
proc findAbstractColumnIndex(line : string) {
  var colNames = createListOfColNames(line);
  for (colIdx,colName) in zip(0..colNames.size-1,colNames) {
    if colName=="abstract" then return colIdx;
  }
  return -1;
}

writeln("Took: ", t.elapsed());