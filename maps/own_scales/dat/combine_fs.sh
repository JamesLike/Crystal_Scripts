#!/bin/bash
#J Baxter 2020
# Script to combine dark Fs, lightFs and Fcalcs and then generated Fext and qweighted maps

script_loc="/mnt/data4/XFEL/LR23/DED_tests/"
dark_model="../dat/Dark.pdb"
dark_model_FC="../dat/dark_F_calc.mtz"
#dark_obs="../dat/dark_new_truncate.mtz"
dark_obs="./AllRuns-mosflm_total_dark_phenix_massage.mtz"
light_obs="./AllRuns-mosflm_fs-400nm-515nm-min50fs-150fs-tagsonly_phenix_massage.mtz"
#light_obs="./Lasers-ON-400nm-515nm-0fs-1ps_new_truncate.mtz"

if [  "X$#" == "X4" ] ; then
	dark_model=$1
	dark_model_FC=$2
	dark_obs=$3
	light_obs=$4
else
    echo
    echo "Usage: make_phenix_q_weight:<dark_model(pdb)><dark_model_FCs (mtz containing FC_all and PHIC_all for the dark model)> <dark_obs (mtz of F and sigF)><light_obs (mtz of F and sigF) >"
    echo
    exit 1
fi

###################################
#Extract and sort multiscaled Fs
###################################
# Usage: <dark_model(pdb)><dark_model_FCs (mtz containing FC_all and PHIC_all for the dark model)> <dark_obs (mtz of F and sigF)><light_obs (mtz of F and sigF) >
${script_loc}/scripts/phenix_gen_scaled_fs.sh $dark_model $dark_model_FC $dark_obs $light_obs

# INPUTS SHOULD BE SORTED ALREADY BY phenix_gen_scaled_fs.sh
#DF or dF are for DARK
awk '{print $1 ,$2,$3,"c",$4,"c",$6}' dark_phases_sorted.hkl > dFC_tmp1 #hkl FC PHFC
awk '{print $1 ,$2,$3,"c",$4,"c",$5}' dark_Fs_scaled.hkl > DFs_tmp1 #hkl F_DARK_OBS SIG_F_DARK_OBS
awk '{print $1 ,$2,$3,"c",$4,"c",$5}' light_Fs_scaled.hkl > LFs_tmp1 #hkl F_LIGHT_OBS SIG_F_LIGHT_OBS
join -tc -j 1 -o 1.1 1.2 1.3 2.2 2.3 dFC_tmp1 DFs_tmp1 > dFC_DFs_tmp1
join -tc -j 1 -o 1.1 1.2 1.3 1.4 1.5 2.2 2.3 dFC_DFs_tmp1 LFs_tmp1 > dFC_DFs_LFs_tmp1 #Gives: hkl FC PHFC DARK_OBS SIG_F_DARK_OBS F_LIGHT_OBS SIG_F_LIGHT_OBS
sed 's/c/ /g' < dFC_DFs_LFs_tmp1 > dFC_DFs_LFs_tmp2 # remove colmn seperateors 
awk '{printf "%5i%5i%5i%12.3f%12.3f%12.3f%12.3f%12.3f%12.3f \n",$1, $2, $3, $4, $5, $6, $7, $8, $9}' dFC_DFs_LFs_tmp2 > all_Fs.hkl

###################################
# Run my python script.. will output diff_map.dat and Fext_map.dat which should be turned into hklthen mtz then map.. 
###################################
rm neg_int.dat COUNT.dat
COUNTER=9
while [ $COUNTER -le 9 ]
do
	python ../scripts/own_scales/extended_map.py $COUNTER
	awk '{printf "%5i%5i%5i%12.3f%12.3f%12.3f \n",$1, $2, $3, $4, $5, $6}' Fext_map.dat > Fext_map.hkl #hkl phFC Fext, sigFext
################
# Turn the extended hkls into mtz then into a map (named neg_map.map) which is fed to the negative integration script (M Scmidt)
################
f2mtz HKLIN Fext_map.hkl HKLOUT James_ext.mtz >log << end_weight 
CELL 39.34  74.01  78.62  90  90  90  # angles default to 90
SYMM 19
LABOUT H   K  L   PHI  Fext  sigFext
CTYPE  H   H  H   P      F   W
END
end_weight

fft HKLIN James_ext.mtz MAPOUT neg_map.map  >log << END-wfft 
RESO 15 1.4
SCALE F1 1.0 0.0
GRID 160 160 140
BINMAPOUT
LABI F1=Fext W=sigFext PHI=PHI
END-wfft

~/scripts/marius/neg_int/neg.sh > neg_${COUNTER}.log 
grep 'SUM NEGATIVE DENSITY :' neg_${COUNTER}.log | awk '{print $5}' >> neg_int.dat
echo $COUNTER >> COUNT.dat

mv neg_map.map Fxt_map_${COUNTER}.map
COUNTER=$(( $COUNTER + 1))
done
###################################
#Organise data
###################################
paste COUNT.dat neg_int.dat > neg_count.dat
awk '{printf "%5i%5i%5i%12.3f%12.3f%12.3f \n",$1, $2, $3, $4, $5, $6}' diff_unweighted_map.dat > diff_unweighted_map.hkl
awk '{printf "%5i%5i%5i%12.3f%12.3f%12.3f \n",$1, $2, $3, $4, $5, $6}' diff_weight_map.dat > diff_weight_map.hkl #hkl phFC Fext, sigFext

###################################
#Generate the unweighted map
echo "Making unwt map"
###################################
f2mtz HKLIN diff_unweighted_map.hkl HKLOUT diff_unweighted_map.mtz << end_weight  >log
CELL 39.34  74.01  78.62  90  90  90  # angles default to 90
SYMM 19
LABOUT H   K  L   PHDOBS  DOBS  FOM
CTYPE  H   H  H   P      F   W
END
end_weight

fft HKLIN diff_unweighted_map.mtz MAPOUT diff_unweighted_map.map << END-wfft >log
  RESO 15 1.4
  GRID 200 200 120
  BINMAPOUT
  LABI F1=DOBS W=FOM PHI=PHDOBS
END-wfft

###################################
#Generate the weighted map
echo "Making wt map"
###################################
f2mtz HKLIN diff_weight_map.hkl HKLOUT diff_weight_map.mtz << end_weight  >weighted_map_log
CELL 39.34  74.01  78.62  90  90  90  # angles default to 90
SYMM 19
LABOUT H   K  L   PHDOBS  DOBS  FOM
CTYPE  H   H  H   P      F   W
END
end_weight

fft HKLIN diff_weight_map.mtz MAPOUT diff_weight_map.map << END-wfft >weighted_map_log
  RESO 15 1.4
  GRID 200 200 120
  BINMAPOUT
  LABI F1=DOBS W=FOM PHI=PHDOBS
END-wfft


echo "Run GNUPLOT code to view output:"
echo "plot \"neg_count.dat\" u 1:(\$2*-1) "

