# Used from command line
# Input: names of .txt files of pupillometry data from EyeLink Data Viewer
# Output: pupillometry data .txt files, but with all "Error messages lost" and "Tracker_Time" messages removed
#		- will deposit new files in same folder script is contained in

# Imports
import sys
import re


def HandleFile(fileName):
	try:
		f1 = open(fileName, 'r')	# open original file for reading
		print 'Handling File...' 

		# Name and file for modified data to write to
		new_name = name[0:-4] + '_mod.txt'
		f2 = open(new_name, 'w')
		print 'Second File Open...'

		# Read file one line at a time, until EOF is reached
		l = f1.readline()
		while l != '':
			# Get rid of Error Mesages Lost message (with other message in sample, or alone)
			l = re.sub('ERROR\sMESSAGES\sLOST\s\d;', '', l)
			l = re.sub('ERROR\sMESSAGES\sLOST\s\d', '.', l)
			# If TRACKER_TIME message ends in semicolon, remove whole thing
			l = re.sub('TRACKER_TIME.+;', '', l)
			# If TRACKER_TIME message is only sample message, replace with "." (and include newline)
			l = re.sub('TRACKER_TIME\s\d{1,2}\s\d{6,8}\.\d{3}', '.', l)

			# Write new data into output file
			f2.write(l)

			# Read next line in input file
			l = f1.readline()

	except Exception as e:
		print e

	finally:
		try:
			# Close files when data is completely read/written
			f1.close()
			f2.close()
			print('Files Handled and Closed')
		except UnboundLocalError as e:
			print e


# Check for command line arguments, and put arguments other than script name into list
filename_list = []
if len(sys.argv) > 1:
	for x in range(1, len(sys.argv)):
		filename_list.append(sys.argv[x])

print('Files to remove messages from: ', filename_list)

# Loop through all files given through command line
for name in filename_list:
	print name
	HandleFile(name)
