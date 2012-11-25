import os
import sys
import csv
import time
import re

f = open("balacera.csv", "r")
csv_file = csv.reader(f, delimiter=',')

# for line in csv_file:
# 	print line[3], line[11]

csvwriter = csv.writer(open("mty_tweets.csv", "w"))
csvwriter.writerow([ "time", "text", "event" ])
# # csvwriter.writerow([ "text", "event" ])

pattern = "monter+ey|mty"
row = 0

for line in csv_file:
	if row != 0:
		try:
			match = re.search(pattern, line[3])
			if match:
				newrow = [ line[11], line[3] , "" ]
				# newrow = [ line[3] , "" ]
				csvwriter.writerow(newrow)
		except:
			pass
	row += 1
