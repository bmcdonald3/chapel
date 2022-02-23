/* abstract-word-count.chpl

   This example demonstrates how to read in a CSV file into an associative
   array indexed by column name and then doing a word count for the "abstract"
   column.

   To run this example, first make sure you have an installation of the
   Chapel compiler. For instructions on how to do that see
   https://chapel-lang.org/docs/master/usingchapel/building.html

   You can compile and run this example on the command line by doing a
       source util/quickstart/setchplenv.bash
   in the Chapel home directory, and then compiling and running this file 
   as follows:
       chpl abstract-word-count.chpl
       ./abstract-word-count

   The example csv file is from Kaggle,
   https://www.kaggle.com/allen-institute-for-ai/CORD-19-research-challenge?select=metadata.csv
   The included metadata-20lines.csv only has 20 lines of data including the
   header row that has the column names.

  References in the Chapel documentation:
    file readers and writers
      https://chapel-lang.org/docs/main/modules/standard/IO.html#i-o-overview
      https://chapel-lang.org/docs/primers/fileIO.html

    associative arrays: https://chapel-lang.org/docs/primers/associative.html
 */
use IO;
use List;
use SortedMap;

config const inFileName = "metadata-morelines.csv";
config const outputFileName = "abstract-word-count.csv";
config const debug = false;
config const minCount = 3;

//-----------------------------------------------------------------------
// Read in the input csv data.

// Open up the input file.
var f = open(inFileName, iomode.r);

// Create a reader of the input csv file
var reader = f.reader();

// Read the first line to get the column names.
// Note: this portion is the same as in Approach 1
var line : string;
if (!reader.readline(line)) then
  writeln("ERROR: ", inFileName, " appears to be empty");

var colNames = createListOfColNames(line);
if debug then writeln("\ncolNames: ", colNames);

// Create a list of lines from the file, so we know how many lines of 
// data there are.  Then create an associative array with an entry per 
// column of data, with the associative key being the column name.  
// The value will be an array of strings with the column's value for 
// each row in the data set.
var dataRows : list(string);

// Reading all of the lines of the file into a list to count number of lines.
while (reader.readline(line)) {
  dataRows.append(line);
}


//-----------------------------------------------------------------------
// create an associative array with the key being 
// the column name and the value being an array of strings

// Declaring an associative array, where the value type is a 1D array 
// large enough to store one column value per row of data.
var valDomain = {0..dataRows.size-1}; // Domain for values per column
// An associative domain of strings
var colNameDomain: domain(string) = colNames;

// colData is an associative array indexed by the column name domain with 
// array values.  Each array value will have number of rows string elements.
var colData: [colNameDomain] [valDomain] string;

// Processing each row to put the column values into the associative array.
// See https://chapel-lang.org/docs/main/users-guide/base/zip.html for
// information about zippered iteration.
for (line, rowIdx) in zip(dataRows, valDomain) {
  // Process each line by finding the next field value from the start 
  // index to the next comma.
  // Doing work quite similar to what is done in Approach 1, but using
  // a Chapel iterator (see fieldsInRow() definition below) and storing
  // the field values in the associative array instead of a list of maps.
  for (colName, field) in zip(colNames, fieldsInRow(line)) {
    colData[colName][rowIdx] = field;
  }
}
reader.close();
f.close();

// Print out all of the data values for the first column of data.
if debug then writeln("\ncolData[colNames[0]]=",colData[colNames[0]]);

//-----------------------------------------------------------------------
// count the number of times each word shows up in the "abstract" column

// declare a Map to maintain the count
var wordCount = new sortedMap(string,int);

// Then count each time a word appears in all the abstracts.
for abstract in colData["abstract"] {
  for word in abstract.split(" ") {
    wordCount[word] += 1;
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

