import numpy as np
from matplotlib import  pyplot as plt
from matplotlib.pyplot import figure

figure(num=None, figsize=(5,4), dpi=400, facecolor='w', edgecolor='k')

data = np.genfromtxt('/home/james/data/crystallography/2020_PAL/stats_frames2.dat')
# Format:
def line_plot(dat, i):
	legend = ['Number of Crystals Merged [1e3]', 'Signal to Noise', 'Redundancy', 'Completeness', 'R$_{Split}$', 'CC*', 'CC']
	colours = ['b','g','c','m','k','r']
	figure(num=None, figsize=(5, 4), dpi=200, facecolor='w', edgecolor='k')
	plt.plot(dat[0, :]/1000, dat[i, :], '.-', color=colours[i-1])
	plt.xlabel(legend[0])
	plt.ylabel(legend[i])
	return

line_plot(data, 1), plt.savefig('/home/james/data/crystallography/2020_PAL/figures/1.pdf'), plt.show()#, plt.show()
# line_plot(data, 4), plt.savefig('/home/james/data/crystallography/2020_PAL/figures/'+legend[4]+'.pdf'#, plt.show()
# line_plot(data, 5), plt.savefig('/home/james/data/crystallography/2020_PAL/figures/'+legend[5]+'.pdf'#, plt.show()
# line_plot(data, 6), plt.savefig('/home/james/data/crystallography/2020_PAL/figures/'+legend[6]+'.pdf'#, plt.show()
#


