import sys
import numpy as np
# J Baxter 2020
# Usage python extended_map.py <N>
# Will make differnce maps of F_light minus F_Dark


file=str(sys.argv[1])
sig_cut_off= 3
N = 1
#Load the data of format:
#0 1 2 3  4    5        6              7           8
#h k l FC PHFC DARK_OBS SIG_F_DARK_OBS F_LIGHT_OBS SIG_F_LIGHT_OBS

data=np.loadtxt(file)
n=0
diff=np.zeros((len(data),6)) # Empty array for the difference map
FEXT=np.zeros((len(data),6)) # Empty array for the extended map
diff_weight = np.zeros((len(data),6))

def sig_prop_neg(sigf1,sigf2): # for f1-f2
    new_sig=np.sqrt(abs(sigf1**2+sigf2**2))
    return new_sig

def weight(DEL_F,AV_DEL_F,SIG_F,DEL_SIG_F): # Weioghts as defined in 10.1016/S0006-3495(03)75018-8
    weights=1/(1+(DEL_F**2/AV_DEL_F)+(SIG_F**2/DEL_SIG_F))
    return weights

del_F_sq_tot = 0
sig_del_F_sq_tot = 0
sigLmD_tot=0
for F in data:
    LmD=F[7]-F[5] # Light minus dark
    sigLmD=sig_prop_neg(F[6],F[8])
    if abs(LmD) > sigLmD*sig_cut_off:
        diff[n]=[F[0],F[1],F[2],F[4],LmD,sigLmD] # Format: hkl PHFC DiffF SIGDiffF
        sigLmD_tot=sigLmD+sigLmD_tot
        del_F_sq_tot = LmD**2 + del_F_sq_tot
        sig_del_F_sq_tot = sigLmD**2 + sig_del_F_sq_tot
        n=n+1

AV_sigLmD_tot=sigLmD_tot/n
AV_del_F_sq = del_F_sq_tot / n
AV_sig_del_F_sq = sig_del_F_sq_tot / n

n=0
w_tot = 0
Fext_uw = 0
FEXT_UW = np.zeros((len(data),6))

for F in data:
    LmD=F[7]-F[5] # Light minus dark
    sigLmD=sig_prop_neg(F[6],F[8])
    if abs(LmD) > sigLmD*sig_cut_off:
        diff[n]=[F[0],F[1],F[2],F[4],LmD,sigLmD]
        Fext_uw = F[3]+(N*LmD)
        sigFext=np.sqrt(abs(N))*sigLmD
        FEXT_UW[n]=[F[0],F[1],F[2],F[4],Fext_uw,sigFext]
        w = weight(LmD,AV_del_F_sq,sigLmD,AV_sig_del_F_sq)
        wF = w * LmD
        diff_weight[n]=[F[0],F[1],F[2],F[4],wF,sigLmD] # Format: hkl PHFC DiffF SIGDiffF
        n=n+1
        w_tot = abs(w) + w_tot

FEXT_UW=FEXT_UW[0:n,:]
diff_weight = np.zeros((len(data),6))
AV_w_tot = w_tot / n
diff=diff[0:n,:]
n=0

for F in data:
    LmD=F[7]-F[5] # Light minus dark
    sigLmD=sig_prop_neg(F[6],F[8])
    if abs(LmD) > sigLmD*sig_cut_off:
        w = weight(LmD,AV_del_F_sq,sigLmD,AV_sig_del_F_sq)
        wF = w * LmD / AV_w_tot # scale by dividing wF by AV_w_tot - This is important for the extrapolated maps!!
        diff_weight[n]=[F[0],F[1],F[2],F[4],wF,sigLmD] # Format: hkl PHFC DiffF SIGDiffF
        w_tot = abs(w) + w_tot
        Fext=F[3]+(N*wF)
        sigFext=np.sqrt(abs(N))*sigLmD
        FEXT[n]=[F[0],F[1],F[2],F[4],Fext,sigFext] # Format: hkl phFC Fext, sigFext
        n=n+1


FEXT=FEXT[0:n,:]
diff_weight=diff_weight[0:n,:]

#np.savetxt("Fext_unw_map.dat",FEXT_UW)
np.savetxt("diff_weight_map.dat",diff_weight)
#np.savetxt("diff_unweighted_map.dat",diff)
#np.savetxt("Fext_map.dat",FEXT)
