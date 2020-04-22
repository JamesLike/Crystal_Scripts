#!/bin/bash
loc="/home/jb2717/PycharmProjects/Crystal_Scripts/maps"
# J Baxter 2020 heavily based on MS in Nat. Methods
# shell script to scale time-resolved and reference data
# and calculate difference maps. 

phasmin=12.0
SYMM=" 19" 

if [  "X$#" == "X8" ] ; then
	dark_model=$1
	model_F=$2
	dark_obs=$3
	light_obs=$4
	res_low=$5 # low res resmax
	scale_high=$6 # high res scalmin / mapmin ? 
	res_high=$6
	map_high=$6 # high res scalmin / mapmin ?
	#bin_nam=$7
	space_group=$8
	bin_nam="Light"
else
	echo
	echo "Usage: <dark model (.pdb)> <dark claculated F (.mtz of FC)> <dark obs (.mtz of F and sigF)> <light obs (.mtz of Fobs sigF) <high res> <low res><file prefix name>"
	echo
	exit 1
fi

echo 'Running make_dmap4_James_edited..'

######################################
# phase file must be calculated from refined model 
# dump the file and add column with 1.0 as sigmas 
######################################
mtz2various HKLIN $model_F  HKLOUT model_phs.hkl << mtz_phs
	LABIN FP=FC_ALL PHIC=PHIC_ALL
	OUTPUT USER '(3I5,F12.3,'  1.00  ',F12.3)'
mtz_phs

######################################
# get the phase file with added sig column into the system
######################################
f2mtz HKLIN model_phs.hkl HKLOUT FC_dark.mtz << f2m_phs 
	CELL ${space_group}
	SYMM ${SYMM}
	LABOUT H   K  L   FC_D SIG_FC_D PHI_D
	CTYPE  H   H  H   F     Q        P
f2m_phs

######################################
# cad things together
######################################
cad HKLIN1 FC_dark.mtz HKLIN2 $dark_obs HKLIN3 $light_obs HKLOUT all.mtz << END-cad
	LABIN FILE 1 E1=FC_D E2=SIG_FC_D E3=PHI_D
	CTYP  FILE 1 E1=F E2=Q E3=P 
	LABIN FILE 2 E1=F E2=SIGF
	CTYP  FILE 2 E1=F E2=Q
	LABO FILE 2 E1=F_Dark E2=SIGF_Dark
	LABIN FILE 3 E1=F E2=SIGF
	LABO FILE 3 E1=F_${bin_nam} E2=SIGF_${bin_nam}
	CTYP  FILE 3 E1=F E2=Q
	END
END-cad

######################################
# scale the things
# labels so far:
# H K L FC_D SIG_FC PHI_D F_Dark SIGF_Dark F_LIGHT SIGF_LIGHT
# 1 scale dark to FC dark
# 2 scale light to dark
echo "SCALEIT 1"
######################################
scaleit HKLIN all.mtz HKLOUT all_sc1.mtz << END-scaleit1
	TITLE FPHs scaled to FP
	RESOLUTION  $scale_high $res_low     # Usually better to exclude lowest resolution data
	#WEIGHT            Sigmas seem to be reliable, so use for weighting
	EXCLUDE FP SIG 4 FMAX 10000000
	REFINE ANISOTROPIC 
	LABIN FP=FC_D SIGFP=SIGF_Dark FPH1=F_Dark SIGFPH1=SIGF_Dark FPH2=F_${bin_nam} SIGFPH2=SIGF_${bin_nam}
	CONV ABS 0.0001 TOLR  0.000000001 NCYC 150
	END
END-scaleit1
#cp all_sc1.mtz all_sc2.mtz
echo "SCALEIT 2"
scaleit HKLIN all_sc1.mtz HKLOUT all_sc2.mtz << END-scaleit2
	TITLE FPHs scaled to FP
	RESOLUTION $scale_high $res_low  # Usually better to exclude lowest resolution data
	#WEIGHT    Sigmas seem to be reliable, so use for weighting
	REFINE ANISOTROPIC 
	EXCLUDE FP SIG 4 FMAX 10000000
	LABIN FP=F_Dark SIGFP=SIGF_Dark FPH1=F_${bin_nam} SIGFPH1=SIGF_${bin_nam}
	CONV ABS 0.0001 TOLR  0.000000001 NCYC 40
	END
END-scaleit2
######################################
# Could add an r_free if needed
######################################

#cp all_sc2.mtz
#free:
#freerflag HKLIN all_sc2.mtz HKLOUT all_sc2_free.mtz <<+
#freerfrac 0.05
#+
######################################
#Make unw maps
echo "Unweighted maps.."
######################################
fft HKLIN all_sc2.mtz MAPOUT ${bin_nam}_nonw.map << endfft
	RESO $map_high $res_low
	GRID 200 200 120
	BINMAPOUT
	LABI F1=F_${bin_nam} SIG1=SIGF_${bin_nam} F2=F_Dark SIG2=SIGF_Dark PHI=PHI_D
endfft
# dump the scaled files to calculate the weighted map
mtz2various HKLIN all_sc2.mtz  HKLOUT light_scaled.hkl << end_mtzv1
     LABIN FP=F_${bin_nam} SIGFP=SIGF_${bin_nam}
     OUTPUT USER '(3I5,2F12.3)'
     RESOLUTION $res_low $res_high
end_mtzv1

mtz2various HKLIN all_sc2.mtz  HKLOUT dark_scaled.hkl << end_mtzv2
     LABIN FP=F_Dark SIGFP=SIGF_Dark
     OUTPUT USER '(3I5,2F12.3)'
     RESOLUTION $res_low $res_high
end_mtzv2

mtz2various HKLIN all_sc2.mtz  HKLOUT dark_phase.hkl << end_mtzv3
     LABIN FP=FC_D SIGFP=SIG_FC_D PHIC=PHI_D
     OUTPUT USER '(3I5,3F12.3)'
     RESOLUTION $phasmin $res_high 
end_mtzv3

######################################
# Then Generate the  inp for marius' scripts
# this will produce a difference structure factor file
# h k l DF weight Phase
# run weighting program
######################################
echo light_scaled.hkl > wmar.inp
echo dark_scaled.hkl >> wmar.inp
echo dark_phase.hkl >> wmar.inp
echo ${bin_nam}_dark.phs >> wmar.inp
echo "Weighting.."
${loc}/progs/weight_zv2 < wmar.inp

######################################
#get files back into mtz
######################################
f2mtz HKLIN ${bin_nam}_dark.phs HKLOUT ${bin_nam}_dwt.mtz << end_weight 
	CELL ${space_group}
	SYMM ${SYMM}
	LABOUT H   K  L   DOBS_${bin_nam}  FOM_${bin_nam}  PHI
	CTYPE  H   H  H   F      W   P
	END
end_weight
######################################
#calculate weighted difference map
######################################
fft HKLIN ${bin_nam}_dwt.mtz MAPOUT ${bin_nam}_wd.map << END-wfft
	RESO $res_low  $map_high 
	GRID 200 200 120
	BINMAPOUT
	LABI F1=DOBS_${bin_nam} W=FOM_${bin_nam} PHI=PHI
END-wfft
######################################
#Extend over the crystal.
######################################

mapmask mapin ${bin_nam}_wd.map mapout ${bin_nam}_wdex.map xyzin $dark_model << ee
	extend xtal
	border 0.0
ee

# rm model_phs.hkl FC_dark.mtz
# rm light_dark.phs
# rm light_scaled.hkl dark_scaled.hkl dark_phase.hkl 
# rm all.mtz all_sc1.mtz all_sc2.mtz

