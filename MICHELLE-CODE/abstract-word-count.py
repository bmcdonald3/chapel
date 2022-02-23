# abstract-word-count.py
#
# Trying to do the same thing as abstract-word-count.chpl.
# FIXME: same goal, but not the same approach.  So won't be an apples
# to apples performance comparison.  Only doing one pass here?
# See https://realpython.com/python-csv/ for reading in csv files.

import time
import csv

start = time.time()

minCount = 3

# dictionary to hold the results
wordCount = {}

# Reading in the file and doing word count at the same time.
with open('metadata.csv') as csv_file:
  csv_reader = csv.reader(csv_file, delimiter=',')
  line_count = 0
  for row in csv_reader:
    if line_count == 0:
      print(f'Column names are {", ".join(row)}')
      line_count +=1
    else:
      #print( row[8] )
      for word in row[8].split():
        wordCount[word] = wordCount.get(word, 0) + 1
      line_count +=1
    #print(f'Processed {line_count} lines.')

# reference: https://stackoverflow.com/questions/1479649/readably-print-out-a-python-dict-sorted-by-key
for key, value in sorted(wordCount.items(), key=lambda x: x[0]):
  if value>minCount:
    print("{} : {}".format(key, value))

print("--- %s seconds ---" % (time.time() - start))
    
#print(wordCount)
