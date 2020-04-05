#!/bin/bash
loc="/home/james/PycharmProjects/Crystal_Scripts/maps"
# J Baxter 01/2020
# This script will get phenix to output the multiscaled F1 and F2, then will write these into files with the Fobs, claulate the scaling factor for each and then calculate the scaled sig fobs
#It will call a custom edited cctx scripts using an install of cctbx's python enviroment edits below:
#import cmath
#import math
#at line 195:
#self.fobs_sac = [fobs_1,fobs_2]
#      print("Saving multisacled F1 and F2")
#      f=open("/tmp/fobs1", "w+")
#      for ai in fobs_1: f.write(str(ai[0][0])+'\t'+str(ai[0][1])+'\t'+str(ai[0][2])+'\t'+str('%.3f' % ai[1])+'\n')
#      f.close()
#      f=open("/tmp/fobs2", "w+")
#      for ai in fobs_2: f.write(str(ai[0][0])+'\t'+str(ai[0][1])+'\t'+str(ai[0][2])+'\t'+str(ai[1])+'\n')
#      f.close()
#      f=open("/tmp/fmodel", "w+")
#      for ai in f_model: f.write(str(ai[0][0])+'\t'+str(ai[0][1])+'\t'+str(ai[0][2])+'\t'+str(180*cmath.phase(ai[1])/math.pi)+'\n')
#      f.close()


if [ ! -d $loc ]; then echo "$loc not found!" && exit 1 ; fi

if [  "X$#" == "X4" ] ; then
	dark_model=$1
	dark_FC=$2
	dark_obs=$3
	light_obs=$4
else
    echo
    echo "Usage: phenix_gen_sclaed_fs:<dark_model(pdb)><dark_model_FCs (mtz containing FC_all and PHIC_all for the dark model)> <dark_obs (mtz of F and sigF)><light_obs (mtz of F and sigF) >"
    echo
    exit 1
fi

phenix.python ${loc}/call.py f_obs_1_file=$light_obs f_obs_2_file=$dark_obs f_obs_1_label=F,SIGF f_obs_2_label=F,SIGF phase_source=$dark_model multiscale=True output_file=phenix_Fobs_Fobs.mtz
mv /tmp/fobs1 ./fobs_light 
mv /tmp/fobs2 ./fobs_dark 
mv /tmp/fmodel ./fmodel
###################################
#Make the light obs data into an hkl ascii to play with..
###################################
mtz2various HKLIN $light_obs  HKLOUT light.hkl << light_to_hkl >> mtz_log
     LABIN FP=F SIGFP=SIGF
     OUTPUT USER '(3I5,F12.3,F12.3)'
light_to_hkl
###################################
#Then match it and sort into a single hkl file of format: h,k,l,fobs scaled,fobs unscaled, sigf unscaled, sigf scaledl
###################################
awk '{print $1,$2,$3,"c",$4}' fobs_light > tmp_light_1
awk '{print $1,$2,$3,"c",$4,$5}' light.hkl > tmp_light_2
sort -tc -n tmp_light_1 > tmp_light_1a
sort -tc -n tmp_light_2 > tmp_light_2a
join -tc -j 1 -o 1.1 1.2 2.2 tmp_light_1a tmp_light_2a > tmp_light_12a
sed 's/c/ /g' < tmp_light_12a > light_Fs 
awk '{$7 = ($6 != 0) ? sprintf("%.3f", $4 * $6 / $5) : "UND"}1' light_Fs > light_Fs_scaled
#Then need to format correctly: hkl format should be columns of 5,5,5,12,12 for hkl fobs sigfobs
awk '{printf "%5i%5i%5i%12.3f%12.3f \n",$1, $2, $3, $4, $7}' light_Fs_scaled > light_Fs_scaled.hkl
#rm tmp_light_1 tmp_light_2 tmp_light_1a tmp_light_2a tmp_light_12a light_Fs light_Fs_scaled light.hkl
###################################
# Now generate the dark equiverlent - shouldnt nee to ortder the dark and light hkls as they should already be compared by phenix
###################################
mtz2various HKLIN $dark_obs  HKLOUT dark.hkl << dark_to_hkl  >> mtz_log
     LABIN FP=F SIGFP=SIGF
     OUTPUT USER '(3I5,F12.3,F12.3)'
dark_to_hkl
###################################
#Then match it and sort into a single hkl file of format: h,k,l,fobs scaled,fobs unscaled, sigf unscaled, sigf scaledl
###################################
awk '{print $1,$2,$3,"c",$4}' fobs_dark > tmp_dark_1
awk '{print $1,$2,$3,"c",$4,$5}' dark.hkl > tmp_dark_2
sort -tc -n tmp_dark_1 > tmp_dark_1a
sort -tc -n tmp_dark_2 > tmp_dark_2a
join -tc -j 1 -o 1.1 1.2 2.2 tmp_dark_1a tmp_dark_2a > tmp_dark_12a
sed 's/c/ /g' < tmp_dark_12a > dark_Fs 
# Then want to scale each SIGF by the same scale used to scale each F (ha ve a check to not divide by 0) 
awk '{$7 = ($5 != 0) ? sprintf("%.3f", $4 * $6 / $5) : "UND"}1' dark_Fs > dark_Fs_scaled 
#Then need to format correctly: hkl format should be columns of 5,5,5,12,12 for hkl fobs sigfobs
awk '{printf "%5i%5i%5i%12.3f%12.3f \n",$1, $2, $3, $4, $7}' dark_Fs_scaled > dark_Fs_scaled.hkl
#rm tmp_dark_1 tmp_dark_2 tmp_dark_1a tmp_dark_2a tmp_dark_12a dark_Fs dark.hkl  #dark_Fs_scaled
###################################
# now need to generate a model file which should be of format hkl F_model SIGF=1 phase
###################################
mtz2various HKLIN $dark_FC  HKLOUT dark_phases.hkl << dark_FCs >> mtz_log
     LABIN FP=FC_ALL PHIC=PHIC_ALL
     OUTPUT USER '(3I5,F12.3,'  1.00  ',F12.3)'
dark_FCs
###################################
# And match it to the relflections in the fobs
###################################
awk '{print $1,$2,$3,"c"}' dark_Fs_scaled.hkl > tmp_dark_phase_1
awk '{print $1,$2,$3,"c",$4,$5,$6}'  dark_phases.hkl > tmp_dark_phase_2
sort -tc -n tmp_dark_phase_1 > tmp_dark_phase_1a
sort -tc -n tmp_dark_phase_2 > tmp_dark_phase_2a
join -tc -j 1 -o 2.1 2.2 tmp_dark_phase_1a tmp_dark_phase_2a > tmp_dark_phase_12a
sed 's/c/ /g' < tmp_dark_phase_12a > dark_phases
awk '{printf "%5i%5i%5i%12.3f%12.3f%12.3f \n",$1, $2, $3, $4, $5, $6}' dark_phases > dark_phases_sorted.hkl
#rm tmp_dark_phase_1 tmp_dark_phase_2 tmp_dark_phase_1a tmp_dark_phase_2a tmp_dark_phase_12a dark_phases dark_phases.hkl
###################################
#Now clean up a bit
###################################
#rm fmodel fobs_dark fobs_light mtz_log 

echo 'Phenix scaling complete..'
