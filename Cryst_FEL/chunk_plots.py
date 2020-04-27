import numpy as np
import matplotlib.pyplot as plt

file1 = '/home/james/Documents/test_images/peaks.dat.npy'
file2 = '/home/james/Documents/test_images/reflect.dat.npy'
allpeaks = np.load(file1)
allrefle = np.load(file2)

#h k l I sigma(I) peak background fs/px ss/px
#0 1 2 3 4        5    6          7     8
a=39.6e-10
b=74.5e-10
c=78.9e-10

def invresolution(a,b,c,h,k,l):
	return np.sqrt((h**2/a**2)+(k**2/b**2)+(l**2/c**2))

sig = 2

cutdat=[]
significant = 0
for line in allrefle:
	if line[3] / line[4] > sig:
		significant = significant + 1
		cutdat = np.append(cutdat,line)




		#if len(cutdat)==0: cutdat=line
		#else: cutdat = np.append(cutdat, line)
#print(np.shape(allrefle))
print(significant/len(allrefle))
#print(significant)
# for val in A:
#     print(val[3])
#     if val[3]>3:
#         if B==[]: B=val
#         else: B=np.append(B,val)

#cutreflect = np.reshape(allrefle, [int(len(cutreflect) / 9), 9])


#plt.scatter(allpeaks[:, 2], allpeaks[:, 3], s=1,label='peaks')
#plt.scatter(1e-9*invresolution(a,b,c,allrefle[:,0],allrefle[:,1],allrefle[:,2]), allrefle[:,3], s=1, label='I')
#plt.scatter(1e-9*invresolution(a,b,c,allrefle[:,0],allrefle[:,1],allrefle[:,2]), allrefle[:,4], s=1, label='sigI')
#plt.scatter(1e-9*invresolution(a,b,c,allrefle[:,0],allrefle[:,1],allrefle[:,2]), allrefle[:,5], s=1,label='peak')
#plt.scatter(1e-9*invresolution(a,b,c,allrefle[:,0],allrefle[:,1],allrefle[:,2]), allrefle[:,6], s=1, label='bckgrouns')
#plt.scatter(1e-9*invresolution(a,b,c,allrefle[:,0],allrefle[:,1],allrefle[:,2]), allrefle[:,3]/allrefle[:,4], s=0.0001, label='I/sigI')
#plt.imshow(allrefle[:,7],allrefle[:,8])
#plt.legend()
#plt.hist2d(allrefle[:,3],allrefle[:,4],1000)
#plt.xlim([-500, 1000])
#plt.ylim([0,10])
#plt.show()



#resolution(a,b,c,22,3,33)*10**10
