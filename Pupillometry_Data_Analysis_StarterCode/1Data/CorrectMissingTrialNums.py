# Used from command line
# Input: names of .txt files of pupillometry data that have had Tracker Time Messages removed (filenames end in "_mod.txt")
# Output: pupillometry data .txt files, but with trial numbers fixed to be sequential (fixing skipped trials)
#		- will deposit new files in same folder script is contained in

# Imports
import sys
import traceback
import re


def HandleFile(fileName):
	try:
		f1 = open(fileName, 'r')	# open original file for reading
		print 'Handling File...' 

		# Name and file for modified data to write to
		new_name = name[0:-4] + '_num.txt'
		f2 = open(new_name, 'w')
		print 'Second File Open...'

		# Keep track of trial number, and offset for missing trial numbers
		trial = 1
		offset = 0
		# Regular expression for finding trial number
		trial_num_regex = '(?<=RO[123456]\t)(\d{1,2})'

		# Read file one line at a time, until EOF is reached
		l = f1.readline()
		while l != '':
			# Split string around trial number
			l_split = re.split(trial_num_regex, l)
			#print l_split
			if len(l_split) > 1:
				t_num = int(l_split[1])

				if t_num != trial:
					if t_num == (trial + offset):
						t_num = t_num - offset
						l_split[1] = str(t_num)
						l = ''.join(l_split)
					elif t_num == (trial + offset + 1):
						trial += 1
						t_num = t_num - offset
						l_split[1] = str(t_num)
						l = ''.join(l_split)
					elif t_num == (trial + offset + 2):
						offset += 1
						trial += 1
						t_num = t_num - offset
						l_split[1] = str(t_num)
						l = ''.join(l_split)

			# Write new data into output file
			f2.write(l)

			# Read next line in input file
			l = f1.readline()

	except Exception as e:
		print ''
		print e
		traceback.print_exc(file=sys.stdout)

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

print('Files correct trial nums for: ', filename_list)

# Loop through all files given through command line
for name in filename_list:
	print name
	HandleFile(name)
