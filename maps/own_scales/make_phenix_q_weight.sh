#!/bin/bash
#J Baxter 2020
# Script to combine dark Fs, lightFs and Fcalcs and then generated Fext and qweighted maps
#script_loc="/mnt/data4/XFEL/LR23/DED_tests/"
script_loc="/home/james/scripts/diff_maps"
#space_group=" 39.34  74.01  78.62  90  90  90  "
#space_group=" 39.60  74.50  78.90  90.00  90.00  90.00" # Serial 
#space_group=" 38.6  73.8  78.1  90  90  90" # Cryo
#space_group=" 38.6  73.5  78.0  90  90  90" # Cryo

SYMM=" 19"
Extrap="NO" #if = yes will make extrapmaps


if [  "X$#" == "X7" ] ; then
	dark_model=$1
	dark_model_FC=$2
	dark_obs=$3
	light_obs=$4
	space_group=$5
	res_high=$6
	res_low=$7
else
	echo
	echo "Usage: make_phenix_q_weight:<dark_model(pdb)><dark_model_FCs (mtz containing FC_all and PHIC_all for the dark model)> <dark_obs (mtz of F and sigF)><light_obs (mtz of F and sigF) > <Cell> <res_high>"
	echo
	exit 1
fi

###################################
#Extract and sort multiscaled Fs
###################################
# Usage: <dark_model(pdb)><dark_model_FCs (mtz containing FC_all and PHIC_all for the dark model)> <dark_obs (mtz of F and sigF)><light_obs (mtz of F and sigF) >
${script_loc}/phenix_gen_scaled_fs.sh $dark_model $dark_model_FC $dark_obs $light_obs

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


rm -f neg_int.dat COUNT.dat

if [ "$Extrap" == "yes" ] ; then 
	COUNTER=1
	while [ $COUNTER -le 2 ] ; do
		COUNT=$(echo "scale=2; $COUNTER/10" | bc -l)
		echo "Processing $COUNT"
		python ${script_loc}scripts/own_scales/extended_map.py $COUNTER
		awk '{printf "%5i%5i%5i%12.3f%12.3f%12.3f \n",$1, $2, $3, $4, $5, $6}' Fext_map.dat > Fext_map.hkl #hkl phFC Fext, sigFext
		awk '{printf "%5i%5i%5i%12.3f%12.3f%12.3f \n",$1, $2, $3, $4, $5, $6}' Fext_unw_map.dat > Fext_unw_map.hkl #hkl phFC Fext, sigFext
		################
		# Turn the extended hkls into mtz then into a map (named neg_map.map) which is fed to the negative integration script (M Scmidt)
		################
		f2mtz HKLIN Fext_map.hkl HKLOUT James_ext.mtz >log << end_weight 
		CELL${space_group}
		SYMM${SYMM}
		LABOUT H   K  L   PHI  Fext  sigFext
		CTYPE  H   H  H   P      F   Q
		END
end_weight
	
		fft HKLIN James_ext.mtz MAPOUT neg_map.map  >log << END-wfft 
		RESO 15 $resmax
		SCALE F1 1.0 0.0
		GRID 160 160 140
		BINMAPOUT
		LABI F1=Fext SIG1=sigFext PHI=PHI
END-wfft
	
		#${script_loc}/neg.sh > neg_${COUNTER}.log 
		#grep 'SUM NEGATIVE DENSITY :' neg_${COUNTER}.log | awk '{print $5}' >> neg_int.dat
		#echo $COUNT >> COUNT.dat
		
		mv neg_map.map Fxt_map_${COUNTER}.map
		###################################
		#Now maqke the unweighted map
		###################################
		f2mtz HKLIN Fext_unw_map.hkl HKLOUT James_unw_ext.mtz >log << end_weight 
		#CELL 39.34  74.01  78.62  90  90  90  # angles default to 90
		#SYMM 19
		CELL${space_group}
		SYMM${SYMM}
		LABOUT H   K  L   PHI  Fext  sigFext
		CTYPE  H   H  H   P      F   Q
		END
end_weight
			
		fft HKLIN James_unw_ext.mtz MAPOUT neg_map.map  >log << END-wfft 
		RESO 15 $resmax
		SCALE F1 1.0 0.0
		#GRID 160 160 140
		BINMAPOUT
		LABI F1=Fext SIG1=sigFext PHI=PHI
END-wfft
	
		~/scripts/marius/neg_int/neg.sh > neg_unw_${COUNTER}.log 
		grep 'SUM NEGATIVE DENSITY :' neg_unw_${COUNTER}.log | awk '{print $5}' >> neg_unw_int.dat
		mv neg_map.map Fxt_unw_map_${COUNTER}.map
		mv James_unw_ext.mtz Fxt_unw_${COUNTER}.mtz
		COUNTER=$(( $COUNTER + 10))
	done

	paste COUNT.dat neg_unw_int.dat > neg_unw_count.dat
	paste COUNT.dat neg_int.dat  > neg_count.dat
	gnuplot -e "set terminal png size 800,600; set output 'count.png'; set xlabel 'N_{EXT}'; set ylabel 'Integrated negative electron density (arb.)'; set key off ; plot 'neg_count.dat' using 1:(\$2*-1) with linespoints"
	echo "Run GNUPLOT code to view output:"
	echo "plot \"neg_count.dat\" u 1:(\$2*-1) "
	else 
	echo
	echo "Not running Extrapolated maps"
	echo
	python ${script_loc}/own_scales/extended_map.py 0
fi



###################################
#Organise data
###################################

awk '{printf "%5i%5i%5i%12.3f%12.3f%12.3f \n",$1, $2, $3, $4, $5, $6}' diff_unweighted_map.dat > diff_unweighted_map.hkl
awk '{printf "%5i%5i%5i%12.3f%12.3f%12.3f \n",$1, $2, $3, $4, $5, $6}' diff_weight_map.dat > diff_weight_map.hkl #hkl phFC Fext, sigFext

###################################
#Generate the unweighted map
echo "Making unwt map"
###################################
f2mtz HKLIN diff_unweighted_map.hkl HKLOUT diff_unweighted_map.mtz << end_weight  >log
	CELL ${space_group}
	SYMM ${SYMM}
	LABOUT H   K  L   PHDOBS  DOBS  FOM
	CTYPE  H   H  H   P      F   W
	END
end_weight

fft HKLIN diff_unweighted_map.mtz MAPOUT diff_unweighted_map.map << END-wfft >log
	RESO $res_low $res_high
	GRID 200 200 120
	BINMAPOUT
	LABI F1=DOBS W=FOM PHI=PHDOBS
END-wfft

###################################
#Generate the weighted map
echo "Making wt map"
###################################
f2mtz HKLIN diff_weight_map.hkl HKLOUT diff_weight_map.mtz << end_weight  >weighted_map_log
	CELL ${space_group}
	SYMM ${SYMM}
	LABOUT H   K  L   PHDOBS  DOBS  FOM
	CTYPE  H   H  H   P      F   W
	END
end_weight

fft HKLIN diff_weight_map.mtz MAPOUT diff_weight_map.map << END-wfft >weighted_map_log
	RESO $res_low $res_high
	GRID 200 200 120
	BINMAPOUT
	LABI F1=DOBS W=FOM PHI=PHDOBS
END-wfft

#rm Fxt_map*



