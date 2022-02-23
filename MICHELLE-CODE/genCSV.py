#!/usr/bin/python
import csv
import random

records=1024*128
print("Making %d records\n" % records)

fieldnames=['id','name','age','city', 'id1','name1','age1','city1', 'abstract','name2','age2','city2', 'id3','name3','age3','city3', 'id4','name4','age4','city4', 'id5','name5','age5','city5']
writer = csv.DictWriter(open("people.csv", "w"), fieldnames=fieldnames)

names=['Deepak', 'Sangeeta', 'Geetika', 'Anubhav', 'Sahil', 'Akshay']
cities=['Delhi', 'Kolkata', 'Chennai', 'Mumbai']

writer.writerow(dict(zip(fieldnames, fieldnames)))
for i in range(0, records):
  writer.writerow(dict([
      ('id', i),
      ('name', random.choice(names)),
      ('age', str(random.randint(24,26))),
      ('city', random.choice(cities)),
      ('id1', i),
      ('name1', random.choice(names)),
      ('age1', str(random.randint(24,26))),
      ('city1', random.choice(cities)),
      ('abstract', i),
      ('name2', random.choice(names)),
      ('age2', str(random.randint(24,26))),
      ('city2', random.choice(cities)),
      ('id3', i),
      ('name3', random.choice(names)),
      ('age3', str(random.randint(24,26))),
      ('city3', random.choice(cities)),
      ('id4', i),
      ('name4', random.choice(names)),
      ('age4', str(random.randint(24,26))),
      ('city4', random.choice(cities)),
      ('id5', i),
      ('name5', random.choice(names)),
      ('age5', str(random.randint(24,26))),
      ('city5', random.choice(cities))]))
