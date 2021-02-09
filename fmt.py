import sys

tabs = -1

def write(char):
	for i in range(tabs):
		sys.stdout.write('\t')
	sys.stdout.write(char)

def nl():
	sys.stdout.write('\n')
	for i in range(tabs):
		sys.stdout.write('\t')

s = sys.stdin.read()
s1 = s.split(' ')
for word in s1:
	for char in word:
		if char == '[':
			tabs += 1
			nl()
			sys.stdout.write(char)
		elif char == ']':
			tabs -= 1
			sys.stdout.write(char)
		elif char == ' ':
			pass
		elif char == ',':
			sys.stdout.write(char)
			sys.stdout.write(' ')
		else:
			sys.stdout.write(char)

