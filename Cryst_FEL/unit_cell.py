
import os
import sys
import numpy as np
import matplotlib.pyplot as plt

if len(sys.argv) != 3:
	print(len(sys.argv))
	print(sys.argv)
	print('Wrong Args!')
	exit()

#path = '/home/james/data/crystallography/2020_PAL/cells/'
#os.system("grep 'Cell pa' laser-off.stream | awk '{print $3, $4, $5, $7, $8, $9}' > cells.dat")

#cells = np.loadtxt(path + 'cells.dat', delimiter=' ')
cells = np.loadtxt(sys.argv[1])
a = []; b = []; c = []; alph = []; beta = []; gamma = []
for val in cells:
	a.append(val[0])
	b.append(val[1])
	c.append(val[2])
	alph.append(val[3])
	beta.append(val[4])
	gamma.append(val[5])

plt.clf()
fig, ax = plt.subplots(2,3)
#plt.title(sys.argv[2])
ax[0,0].hist(a, 100)
ax[0,0].set(xlabel='a [nm]')
ax[0,0].set_xlim([3.8, 4.0])

ax[0,1].hist(b, 100)
ax[0,1].set(xlabel='b [nm]')
ax[0,1].set_xlim([7.2, 7.6])

ax[0,2].hist(c, 100)
ax[0,2].set(xlabel='c [nm]')
ax[0,2].set_xlim([7.6, 8.0])

ax[1,0].hist(alph, 100)
ax[1,0].set(xlabel='Alpha [deg]')
ax[1,0].set_xlim([88, 92])

ax[1,1].hist(beta, 100)
ax[1,1].set(xlabel='Beta [deg]')
ax[1,1].set_xlim([88, 92])

ax[1,2].hist(gamma, 100)
ax[1,2].set(xlabel='Gamma [deg]')
ax[1,2].set_xlim([88, 92])

#ax.axes.xaxis.set_visible(False)
[axi.axes.yaxis.set_visible(False) for axi in ax.ravel()]
plt.tight_layout()
plt.savefig(sys.argv[2]+'-laser-off.pdf')