import matplotlib.pyplot as plt


# file = '/home/james/Documents/test_images/tmpcrystfel_xgandalf.stream'
file = '/home/james/Documents/test_images/crystfel_xgandalf.stream'
# streamfile = open(file, 'r')
# raw = streamfile.read()
# Determine how many chunks:
sum = 0
with open(file) as fp:
	for line in fp:
		if line == '----- Begin chunk -----\n':
			sum = sum + 1

dat = [None] * (sum)
idx = 0
with open(file) as fp:
	for line in fp:
		if line == '----- Begin chunk -----\n':
			idx = idx + 1
			dat[idx - 1] = line
		if idx > 0:
			dat[idx - 1] = dat[idx - 1] + line

indexed = []
for chunk in dat:
	if 'indexed_by = none' not in chunk:
		indexed.append(chunk)

import numpy as np


def between(str, a, b):
	i = str.find(a) + len(a)
	j = str.find(b)
	return str[i:j]


def reflectsort(line):
	h = float(line[0:4])
	k = float(line[5:9])
	l = float(line[10:14])
	I = float(line[14:26])
	sigI = float(line[27:36])
	peak = float(line[37:47])
	bck = float(line[48:58])
	x = float(line[59:65])
	y = float(line[66:72])
	return [h, k, l, I, sigI, peak, bck, x, y]


def peaksort(line):
	x = float(line[0:7])
	y = float(line[8:15])
	d = float(line[16:26])
	I = float(line[26:38])
	return [x, y, d, I]


def indexedsort(indexed):
	peakstart = "  fs/px   ss/px (1/d)/nm^-1   Intensity  Panel\n"
	peakend = "End of peak list\n"
	cryststart = "   h    k    l          I   sigma(I)       peak background  fs/px  ss/px panel"
	crystend = "End of reflections"
	reflect = (between(indexed, cryststart, crystend).split('\n'))
	peaks = (between(indexed, peakstart, peakend).split('\n'))
	tmp = []
	for line in peaks:
		if line != '':
			tmp.append(peaksort(line))
	peaks = np.asarray(tmp)

	tmp = []
	for line in reflect:
		if line != '':
			tmp.append(reflectsort(line))
	reflect = np.asarray(tmp)

	return [peaks, reflect]


allpeaks = []
allrefle = []

for val in indexed:
	p, f = indexedsort(val)
	if allpeaks == []:
		allpeaks = p
	else:
		allpeaks = np.append(allpeaks, p)
	if allrefle == []:
		allrefle = f
	else:
		allrefle = np.append(allrefle, f)

allpeaks = np.reshape(allpeaks, [int(len(allpeaks) / 4), 4])
allrefle = np.reshape(allrefle, [int(len(allrefle) / 9), 9])

plt.scatter(allpeaks[:, 2], allpeaks[:, 3])
plt.show()

file1 = '/home/james/Documents/test_images/peaks.dat'
file2 = '/home/james/Documents/test_images/reflect.dat'
np.save(file1,allpeaks)
np.save(file2,allrefle)
