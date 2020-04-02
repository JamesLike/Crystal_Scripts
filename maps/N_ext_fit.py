import numpy as np
import matplotlib.pyplot as plt

file = "neg_count_Mari.dat"
data=np.loadtxt(file)
data[:,1]=-1*data[:,1]
reg0=np.inf

def m(a,b): 
    diff=(abs(a)-abs(b))**2
    return diff

for n in range(2,len(data)-2):

    x1=data[0:n,0]
    y1=(data[0:n,1])
    x2=data[n:len(data)-1,0]
    y2=data[n:len(data)-1,1]
    coef1 = np.polyfit(x1,y1,1)
    coef2 = np.polyfit(x2,y2,1)
    fn_1 = np.poly1d(coef1) 
    fn_2 = np.poly1d(coef2) 
    idx,sum_model_diff,sum_y1, mean_sum_Y = 0, 0, 0, 0
    MIN2=0
    SUMFN1=0
    
    
    for val in y1:
        sum_y1 = abs(val) + sum_y1
        idx=idx+1
    mean_y1=sum_y1/idx
    
    for val in y1:
        sum_model_diff =  m(fn_1[idx],mean_y1) + sum_model_diff
        mean_sum_Y = m(val, mean_y1) + mean_sum_Y
    reg1 =(sum_model_diff / mean_sum_Y )

    idx,sum_model_diff,sum_y2, mean_sum_Y = 0, 0, 0, 0
 
    for val in y2:
        sum_y2 = val + sum_y2
        idx=idx+1
        #print(val)
    mean_y2=sum_y2/idx
    for val in y2:
        sum_model_diff =  m(fn_2[idx],mean_y2) + sum_model_diff
        mean_sum_Y = m(val, mean_y2) + mean_sum_Y
    reg2 =(sum_model_diff / mean_sum_Y )
    
    reg=np.sqrt(reg1**2+reg2**2)
    
    if reg < reg0:
        reg0=reg
        #print(n)
        N=n
        
    
x1=data[0:N,0]
y1=abs(data[0:N,1])
x2=data[N:len(data),0]
y2=abs(data[N:len(data),1])
coef1 = np.polyfit(x1,y1,1)
coef2 = np.polyfit(x2,y2,1)
fn_1 = np.poly1d(coef1) 
fn_2 = np.poly1d(coef2)

X1=np.linspace(min(x1),(x2[2]))
X2=np.linspace(x1[-2],max(x2))

intersectx =np.around((coef2[1]-coef1[1])/(coef1[0]-coef2[0]),2)
intersecty = coef2[0] * intersectx +coef2[1]
sav=np.array(intersectx)

fig = plt.figure()
ax1 = fig.add_subplot(111)
ax1.set_ylabel('Integrated Electron Density (arb.)')
ax1.set_xlabel('$N_{EXT}$')
ax1.annotate(intersectx, xy=(intersectx,intersecty), xytext=(intersectx, (np.max(data[:,1])/2)),arrowprops=dict(facecolor='black', shrink=0.05))
ax1.plot(data[:,0],data[:,1],"o",X1,fn_1(X1),X2,fn_2(X2))
plt.savefig('N_ext_Fitted.png')

open("FIT.dat","w").write(str(intersectx))
open("FIT.dat","w").close()

