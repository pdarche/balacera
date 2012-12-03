import os
import sys
import csv
import time
import re

f = open("balacera-nov.csv", "r")
csv_file = csv.reader(f, delimiter=',')

csvwriter = csv.writer(open("to-label.csv", "w"))
csvwriter.writerow([ "time", "text", "event" ])

pattern = "monter+ey|mty"
row = 0

for line in csv_file:
	if row != 0:
		try:
			# match = re.search(pattern, line[3])
			# if match:
			newrow = [ line[11], line[3] , "" ]
			# newrow = [ line[3] , "" ]
			# csvwriter.writerow(newrow)
			print newrow
		except:
			pass
	row += 1
