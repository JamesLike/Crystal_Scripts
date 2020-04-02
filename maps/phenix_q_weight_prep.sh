#!/bin/bash
# J Baxter 01/2020
#This scripts will take the multiscaled phenix output make differnce maps using marius scripts.
#space_group=" 39.34  74.01  78.62  90  90  90" #FEL
SYMM=" 19"
if [  "X$#" == "X7" ] ; then
	dark_model=$1
	dark_FC=$2
	dark_obs=$3
	light_obs=$4
	bin_nam=$5
	mapmin=$6
	resmax=$7
	space_group=$8
else
    echo
    echo "Usage: phenix_q_weight_prep:<dark_model(pdb)><dark_model_FCs (mtz containing FC_all and PHIC_all for the dark model)> <dark_obs (mtz of F and sigF)><light_obs (mtz of F and sigF) > <output_name_prefix <high_res_cut><low res cut><cell>"
    echo
    exit 1
fi




#	dark_model="a/Dark.pdb"
#	dark_FC="a/dark_F_calc.mtz"
#	dark_obs="a/dark_new_truncate.mtz"
#	light_obs="a/light_new_truncate.mtz"
#	bin_nam="name"
#	mapmin=1.32
#	resmax=15.40



/mnt/data4/XFEL/LR23/DED_tests/scripts/phenix_gen_scaled_fs.sh $dark_model $dark_FC $dark_obs $light_obs

echo light_Fs_scaled.hkl > wmar.inp
echo dark_Fs_scaled.hkl >> wmar.inp
echo dark_phases_sorted.hkl >> wmar.inp
echo ${bin_nam}_phenix_scaled_dark.phs >> wmar.inp

echo "Weighting maps woth Marius scripts.. "
~/progs/marius/scripts/PROGS/weight_zv2 < wmar.inp

f2mtz HKLIN ${bin_nam}_phenix_scaled_dark.phs HKLOUT ${bin_nam}_phenix_scaled_dwt.mtz << end_weight 
CELL ${space_group} # angles default to 90
SYMM 19
LABOUT H   K  L   DOBS  FOM  PHI
CTYPE  H   H  H   F      W   P
END
end_weight

fft HKLIN ${bin_nam}_phenix_scaled_dwt.mtz MAPOUT ${bin_nam}_phenix_scaled_wd.map << END-wfft
  RESO $mapmin  $resmax 
#  GRID 200 200 120
  BINMAPOUT
  LABI F1=DOBS W=FOM PHI=PHI
END-wfft

mapmask mapin ${bin_nam}_phenix_scaled_wd.map mapout ${bin_nam}_phenix_scaled_wdex.map xyzin $dark_model << ee
extend xtal
border 0.0
ee




