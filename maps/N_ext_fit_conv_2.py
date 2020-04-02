from scipy.signal import savgol_filter
from scipy.signal import step
import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit
import sys 

file=str(sys.argv[1])

#file = "neg_count_Mari.dat"
#file = "neg_count.dat"
data=np.loadtxt(file)
data[:,1]=-1*data[:,1]

poly=1
win=5
x=data[:,0]
y=abs(data[:,1])

dary = np.gradient(y)
dary -= np.average(dary)
step = np.hstack((np.ones(len(dary)), -1*np.ones(len(dary))))
dary_step = np.convolve(dary, step, mode='valid')
# get the peak of the convolution, its index
step_indx = np.argmax(dary_step)  # yes, cleaner than np.where(dary_step == dary_step.max())[0][0]
# plots
plt.plot(dary)
plt.plot(dary_step/10)
plt.plot((step_indx, step_indx), (dary_step[step_indx]/10, 0), 'r')


N=step_indx

index=0
for val in data[:,0]:
    if val < 2:
        index = index + 1

if index < 3:
    index = 3
N1=index
index=0

x1=data[0:N1,0]
y1=abs(data[0:N1,1])
x2=data[N:len(data),0]
#x2=data[N:60,0]
y2=abs(data[N:len(data),1])
#y2=abs(data[N:60,1])
coef1 = np.polyfit(x1,y1,1)
coef2 = np.polyfit(x2,y2,1)
fn_1 = np.poly1d(coef1) 
fn_2 = np.poly1d(coef2)

i=abs(data[-1,1])

lim= (-0.01*abs(abs(coef1[0])-abs(data[-1,1])))
i=np.argmin(data[:,1])
if abs(lim) < abs(coef1[0]):
    if i>0:
        x1=data[i-1:i+2,0]
        y1=abs(data[i-1:i+2,1])
        coef1 = np.polyfit(x1,y1,1)
        fn_1 = np.poly1d(coef1)
intersectx =np.around((coef2[1]-coef1[1])/(coef1[0]-coef2[0]),3)
intersecty = coef2[0] * intersectx +coef2[1]

X1=np.linspace(min(data[:,0]),1.1*intersectx)
X2=np.linspace(0.9*intersectx,max(x2))

fig = plt.figure()
ax1 = fig.add_subplot(111)
ax1.set_ylabel('Integrated Electron Density (arb.)')
ax1.set_xlabel('$N_{EXT}$')
ax1.annotate(intersectx, xy=(intersectx,intersecty), xytext=(intersectx, (np.max(data[:,1])/2)),arrowprops=dict(facecolor='black', shrink=0.05))
ax1.plot(data[:,0],data[:,1],"o",X1,fn_1(X1),X2,fn_2(X2))

plt.savefig('N_ext_Fitted_C.png')


print 'Min at:',intersectx 
open("FIT_C.dat","w").write(str(intersectx))
open("FIT_C.dat","w").close()

