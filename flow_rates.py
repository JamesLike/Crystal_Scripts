#%%
import numpy as np
from matplotlib import pyplot as plt

def pH(alph):
	pka = 61.10
	HCL = 398#125.89
	return pka + np.log(alph / HCL)

x = np.linspace(100,200)

plt.plot(x, pH(x))
plt.xlabel('Salt conc [mM]]')
plt.ylabel('pH')

plt.show()

def conc(v):
	c1 = 100
	v1 = 300
	return (c1*v1 + 5e3*v) / (v1+v)

X = np.linspace(0,10)

plt.plot(X, conc(X))
plt.xlabel('Vaolume added [ul]')
plt.ylabel('mM')

plt.show()



plt.plot(X, pH(conc(X)))
plt.xlabel('Vaolume added [ul]')
plt.ylabel('pH')
plt.show()