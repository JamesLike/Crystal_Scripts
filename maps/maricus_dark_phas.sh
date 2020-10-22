#!/bin/bash
loc="/home/james/PycharmProjects/Crystal_Scripts/maps"
SYMM="173"
if ["X$#" == "X5" ] ; then
  pdb=$1 #DARK PDB
  cell=$(${loc}/pdb_cell.sh $dark_model)
  dark_FC=$2
  res_high=$3
  res_low=$4
  original_extrap_map=$5 ## Can be any extrapolated mtz that was generates previously - is only used to meatch reflection indicies
  refined_pdb=$6
else
  echo "Usage: maricus darkphases  <dark pdb> <dark_FC> <res_high> <res_low>  <extrapolated mtz> <extrapolated pdb coordinates> MAKE SURE TO UPDATE SYM AT THE TOP OF THIS SCRIPT!"
  exit 1
fi

name="1_12k_0pol"
light_FC="Light_extrapolated_coord_FC" # This is the name of the structure factors caluclated from refined_pdb

#pdb=""
#refined_pdb="" #Coordinates that have been refined to the extrapolated map
#dark_FC="" # This shouldbe the calculated structure factors form the dark model

resmax=res_high
scalmin=res_low
mapmin=res_low
 # This should be the extrapolated map that was previoudly calculated using the dark phases

sfall HKLIN $original_extrap_map XYZIN $refined_pdb HKLOUT $light_FC << eof-sfall
# Set the mode for structure factor calc. from a xyzin
      MODE sfcalc hklin xyzin
      CELL ${CELL}
      LABIN FP=F_${name} SIGFP = SIGF_${name}
      LABOUT FC=FC_${name} PHIC=PHIC_${name}
      RESOLUTION 37 $resmax
      symmetry ${SYMM}
      end
eof-sfall

cad HKLIN1 $dark_FC HKLIN2 $light_FC HKLOUT all.mtz << END-cad
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

scaleit HKLIN all.mtz  HKLOUT all_sc1.mtz  << END-scaleit1
TITLE FPHs scaled to FP
reso $scalmin $resmax      # Usually better to exclude lowest resolution data
#WEIGHT            Sigmas seem to be reliable, so use for weighting
#refine anisotropic
#Exclude FP data if: FP < 5*SIGFP & if FMAX > 1000000
EXCLUDE FP SIG 4 FMAX 10000000
#AUTO
LABIN FP=FC_DARK SIGFP=SIGF_DARK
  FPH1=FC_${tim} SIGFPH1=SIGF_${tim}
CONV ABS 0.000001 TOLR  0.00000001 NCYC 100
END
END-scaleit1
#
#freerflag HKLIN all_sc1.mtz HKLOUT all_sc1_free.mtz <<+
#freerfrac 0.05
#+


#fft HKLIN all_sc1.mtz MAPOUT ${name}_diff_nonph.map << endfft
#  RESO $mapmin  $resmax
#  GRID 160 160 120
#  BINMAPOUT
#  LABI F1=FC_${tim} SIG1=SIGF_${tim} F2=FC_DARK SIG2=SIGF_DARK PHI=PHIC_DARK
#endfft
# dump the scaled files to calculate the weighted map

mtz2various HKLIN all_sc1.mtz  HKLOUT light_scaled.hkl << end_mtzv1
     LABIN FP=FC_${name} SIGFP=SIGF_${name} PHIC = PHIC_${tim}
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
echo ${name}_dark_calc.phs >> wmar.inp
${loc}/progs/mock-dark < wmar.inp

#get files back into mtz
f2mtz HKLIN ${name}_dark_calc.phs HKLOUT ${name}_dphs.mtz << end_weight
CELL ${CELL
SYMM ${SYMM}
LABOUT H   K  L   FC_D_L DUM  DPHI
CTYPE  H   H  H   F       Q    P
END
end_weight

fft HKLIN ${name}_dphs.mtz MAPOUT ${name}_diff_phased.map << END-wfft
  RESO $mapmin  $resmax
  GRID 160 160 120
  BINMAPOUT
  LABI F1=FC_D_L PHI=DPHI
END-wfft

mapmask mapin ${name}_diff_phased.map mapout ${name}_diff_phased_wdex.map xyzin $pdb << ee
extend xtal
border 0.0
ee

echo "Done (hopefully)"

