

#!/bin/tcsh


# edit here ===>


# dark state model,  only for map extension, does not play a role for calculation:
set dark_model = ../../DARK/REFINE/dark_HCC_v6.pdb



# calculate here difference map from calculated FC
# WITH pases!!!
# ONLY FCs REQUIRED

set dark_FC = ../../DARK/REFINE/FOBS_dark1.mtz


set tim = 30ps
set add = 30
set resmax = 1.6
set scalmin = 20.0
set mapmin = 20.0


# use 10ps_extra_30.mtz
set extra = ../EXTRAPOLATE/30ps_extra_30.mtz
set refi_model = ../EXTRAPOLATE/30ps_HCC_cis_EuXFEL_stepped.pdb

sfall HKLIN $extra XYZIN $refi_model  HKLOUT model_tt.mtz << eof-sfall

# Set the mode for structure factor calc. from a xyzin
      MODE sfcalc hklin xyzin
      CELL 66.9   66.9   40.8 90.0 90.0 120.0
      LABIN FP=F_${tim} SIGFP = SIGF_${tim}
      LABOUT FC=FC_${tim} PHIC=PHIC_${tim}
      RESOLUTION 37 $resmax
      symmetry 173
      end
eof-sfall

set light_FC = model_tt.mtz

# generate light from model


# =============================



# =============================

# phase file must have been calculated from refined model in DARK
# cad things together

cad             \
HKLIN1 $dark_FC    \
HKLIN2 $light_FC     \
HKLOUT all.mtz \
<< END-cad

LABIN FILE 1 E1=FC_DARK E2=SIGF_DARK E3=PHIC_DARK
CTYP  FILE 1 E1=F E2=Q E3=P
LABIN FILE 2 E1=FC_${tim} E2=SIGF_${tim} E3=PHIC_${tim}
CTYP  FILE 2 E1=F E2=Q E3=P


END
END-cad

# go through pipeline
#
# scale the things, all on absolute scale
# labels so far:
# H K L FC_DARK  PHIC_DARK SIGF_DARK FC_${tim} SIGF_${tim} PHIC_${tim}
# 2 scale FClight to FCdark


echo " SCALEIT NUMBER 1, MARIUS CHECK "


scaleit \
HKLIN all.mtz    \
HKLOUT all_sc1.mtz    \
<< END-scaleit1
TITLE FPHs scaled to FP
reso $scalmin $resmax      # Usually better to exclude lowest resolution data
#WEIGHT            Sigmas seem to be reliable, so use for weighting
#refine anisotropic
#Exclude FP data if: FP < 5*SIGFP & if FMAX > 1000000
EXCLUDE FP SIG 4 FMAX 10000000
#AUTO
LABIN FP=FC_DARK SIGFP=SIGF_DARK  -
  FPH1=FC_${tim} SIGFPH1=SIGF_${tim}
CONV ABS 0.000001 TOLR  0.00000001 NCYC 100
END
END-scaleit1

freerflag HKLIN all_sc1.mtz HKLOUT all_sc1_free.mtz <<+
freerfrac 0.05
+


echo "MARIUS unweighted, unphased maps"


fft HKLIN all_sc1.mtz MAPOUT ${tim}_diff_nonph.map << endfft
  RESO $mapmin  $resmax
  GRID 160 160 120
  BINMAPOUT
  LABI F1=FC_${tim} SIG1=SIGF_${tim} F2=FC_DARK SIG2=SIGF_DARK PHI=PHIC_DARK
endfft


# dump the scaled files to calculate the weighted map

mtz2various HKLIN all_sc1.mtz  HKLOUT light_scaled.hkl << end_mtzv1
     LABIN FP=FC_${tim} SIGFP=SIGF_${tim} PHIC = PHIC_${tim}
     OUTPUT USER '(3I5,3F12.3)'
     RESOLUTION 60.0 $resmax
end_mtzv1


mtz2various HKLIN all_sc1.mtz  HKLOUT dark_scaled.hkl << end_mtzv2
     LABIN FP=FC_DARK SIGFP=SIGF_DARK PHIC = PHIC_DARK
     OUTPUT USER '(3I5,3F12.3)'
     RESOLUTION 60.0 $resmax
end_mtzv2




# this is the wmar.inp file FOR DIFF MAPS ONLY FROM FCALC

echo light_scaled.hkl > wmar.inp
echo light_scaled.hkl >> wmar.inp
echo dark_scaled.hkl >> wmar.inp
echo ${tim}_dark_calc.phs >> wmar.inp


# run summation program
# =======================>

echo "Marius get into one file"

../../PROGS/mock-dark < wmar.inp

#
#

# ============== GOTO PROGRAM END =====
#goto pend


#get files back into mtz
f2mtz HKLIN ${tim}_dark_calc.phs HKLOUT ${tim}_dphs.mtz << end_weight
CELL 66.9   66.9   40.8 90.0 90.0 120.0  # angles default to 90
SYMM 173
LABOUT H   K  L   FC_D_L DUM  DPHI
CTYPE  H   H  H   F       Q    P
END
end_weight


#calculate <phased> difference map

fft HKLIN ${tim}_dphs.mtz MAPOUT ${tim}_diff_phased.map << END-wfft
  RESO $mapmin  $resmax
  GRID 160 160 120
  BINMAPOUT
  LABI F1=FC_D_L PHI=DPHI
END-wfft

mapmask mapin ${tim}_diff_phased.map mapout ${tim}_diff_phased_wdex.map xyzin $dark_model << ee
extend xtal
border 0.0
ee


pend:
