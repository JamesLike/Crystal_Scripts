#!/bin/bash
loc="/home/james/PycharmProjects/Crystal_Scripts/maps"
# J Baxter 2020
# Script will generate 4 maps using different scaling methods:
# 1. Using Marius's merthod: Qwiefghted difference maps scaled using anisotropic b factors then 'refine' scaling, followed then by kraut scaling before making maps.
# 2. Using phenix and its multiscaling methods which is based on the scaling implemented in CNS - having read some of the CNS documenttion it seems this is a form of wilson scaling in resolution bins
# 3. Using the phenix multiscale method followed by marius's qeighting scaripts

#Inputs
if [ ! -d $loc ]; then echo "$loc not found!" && exit 1 ; fi

if [  "X$#" == "X8" ] ; then
	dark_model=$1
	dark_FC=$2
	dark_obs=$3
	light_obs=$4
	name=$5
	res_high=$6 # High res term mapmin
	res_low=$7 # Low res terms "resmax"
	space_group=$8
else
    echo
    echo "Usage: map_generate:<dark_model(pdb)><dark_model_FCs (mtz containing FC_all and PHIC_all for the dark model)> <dark_obs (mtz of F and sigF)><light_obs (mtz of F and sigF) > <output_name_prefix> <high_res_cut><low res cut>"
    echo
    exit 1
fi

echo 'Running map_generate'

#Outputs
phenix_multiscale=$name"_phenix_multiscale.mtz"

#1:Usage: <dark model (.pdb)> <dark claculated F (.mtz of FC)> <dark obs (.mtz of F and sigF)> <light obs (.mtz of Fobs sigF) <high res> <low res>"
${loc}/make_dmap4_James_edited.sh $dark_model $dark_FC $dark_obs $light_obs $res_low $res_high $name "$space_group" 


#2: Phneix multiscale
phenix.fobs_minus_fobs_map f_obs_1_file=$light_obs f_obs_2_file=$dark_obs f_obs_1_label=F,SIGF f_obs_2_label=F,SIGF phase_source=$dark_model multiscale=True output_file=$phenix_multiscale high_res=${res_high}
phenix.mtz2map mtz_file=$phenix_multiscale #This actually has two options for how it scales the map - either by sigmas (the defult) of by volume (alterntive options it seems not to make a diffrence which is used. 
rm -f logfile.log tmp.hkl tmp.mtz
# 3. Phenix multiscale scaling with marius maps 
# Usage: phenix_q_weight_prep:<dark_model(pdb)><dark_model_FCs (mtz containing FC_all and PHIC_all for the dark model)> <dark_obs (mtz of F and sigF)><light_obs (mtz of F and sigF) > <output_name_prefix <high_res_cut><low res cut>"
#/mnt/data4/XFEL/LR23/DED_tests/scripts/phenix_q_weight_prep.sh $dark_model $dark_FC $dark_obs $light_obs $name $mapmin $resmax

