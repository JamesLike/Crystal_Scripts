#!/bin/bash

${filename##*/}

#dark_model="/home/james/Documents/i24/processing/pH5_dark/CCP4i2/CCP4_JOBS/job_10/10_s_i24_ph5_dark_xyzout_prosmart_refmac.pdb"
#dark_I="/home/james/Documents/i24/processing/pH5_dark/dat/chip_gorse_hazel_ivory_velvet.hkl"
#light_I="/home/james/Documents/i24/processing/pH8_dark/dat/chip_alder_ebony2_ficus_carrot.hkl"
dark_model="/home/james/Documents/tmp/testing/file.pdb"
dark_I="/home/james/Documents/tmp/testing/1.hkl"
light_I="/home/james/Documents/tmp/testing/2.hkl"
#dark_FC="/mnt/data4/XFEL/LR23/DED_tests/dat/dark_F_SFALL_calc.mtz"

loc="/home/james/scripts/diff_maps" #script location, no need for trailing /
res_high=1.75 #Highest resolution term eg 1.3
res_low=50 #Lowest resolution term eg 15
SYMM=19 # Symmetry group eg P212121 of 19

if [ ! -f $dark_model ]; then echo "$dark_model not found!" && exit 1 ; fi
if [ ! -f $dark_I ]; then echo "$dark_I not found!" && exit 1 ; fi
if [ ! -f $light_I ]; then echo "$light_I not found!" && exit 1 ; fi
if [ ! -d $loc ]; then echo "$loc not found!" && exit 1 ; fi


cell=$(${loc}/pdb_cell.sh $dark_model)
dark_FC=`echo ../${dark_model##*/} | sed -e 's/\.pdb$/_SFALL.mtz/'`

Light_base=`echo ${light_I##*/} | sed -e 's/\.hkl$//'`
Light_1=`echo ${light_I##*/} | sed -e 's/\.hkl$/_old_truncate.mtz/'`
Light_2=$(echo ${light_I##*/} | sed -e 's/\.hkl$/_new_truncate.mtz/')
Light_3=$(echo ${light_I##*/} | sed -e 's/\.hkl$/_phenix_massage.mtz/')

Dark_base=$(echo ${dark_I##*/} | sed -e 's/\.hkl$//')
Dark_1=$(echo ${dark_I##*/} | sed -e 's/\.hkl$/_old_truncate.mtz/')
Dark_2=$(echo ${dark_I##*/} | sed -e 's/\.hkl$/_new_truncate.mtz/')
Dark_3=$(echo ${dark_I##*/} | sed -e 's/\.hkl$/_phenix_massage.mtz/')

name=${Dark_base}_${Light_base}
name1=${name}"_old_truncate"
name2=${name}"_new_truncate"
name3=${name}"_phenix_massage"

mkdir "$name" -p
cd "$name" || exit
echo "--------------------------------"
echo "Processing $name "
echo "--------------------------------"
echo $dark_model > map.log
echo $dark_I >> map.log
echo $light_I >> map.log

cp $dark_model .
cp $dark_I .
cp $light_I .

######################################
#Quick Functions for later
######################################
move () { 
	mv diff_weight_map.map $1_James_QW.map
	mv Light_nonw.map $1_nonw.map
	mv Light_wdex.map $1_wdex.map
}

pymolfig () {
	rm -f py_tmp.pml
	echo load ${dark_model} > py_tmp.pml
	cp $1 map_mol.ccp4
	echo load map_mol.ccp4 >> py_tmp.pml
	cat ${loc}/view_map.pml >> py_tmp.pml
	pymol -c ./py_tmp.pml
	png_name=`echo $1 | sed -e 's/\.map$//'`
	mv png.png ${png_name}.png
	rm -f map_mol.ccp4
}

makefigs () {
	move $1
	pymolfig $1_James_QW.map
	pymolfig $1_nonw.map
	pymolfig $1_wdex.map
	pymolfig $1_phenix_multiscale_1.ccp4
}

######################################
## Generate Fc from the dark model
######################################
${loc}/generate_FC.sh $dark_model $SYMM 
######################################
## Convert Dark Is and Light Is  
######################################
${loc}/trunc_all_options.sh ${dark_I##*/} $res_high $res_low "$cell"
${loc}/trunc_all_options.sh ${light_I##*/} $res_high $res_low "$cell"
######################################
## Run map gnerate for all pairs 
echo "--------------------------------"
echo "Making Maps: "
echo "--------------------------------"
######################################
${loc}/map_generate.sh ${dark_model##*/} $dark_FC $Dark_1 $Light_1 $name1 $res_high $res_low "$cell" #>>map.log tee 
${loc}/own_scales/make_phenix_q_weight.sh $dark_model $dark_FC $Dark_1 $Light_1 "$cell" $res_high $res_low
makefigs $name1

${loc}/map_generate.sh ${dark_model##*/} $dark_FC $Dark_2 $Light_2 $name2 $res_high $res_low "$cell">>map.log
${loc}/own_scales/make_phenix_q_weight.sh $dark_model $dark_FC $Dark_2 $Light_2 "$cell" $res_high $res_low
makefigs $name2

${loc}/map_generate.sh ${dark_model##*/} $dark_FC $Dark_3 $Light_3 $name3 $res_high $res_low "$cell">>map.log
${loc}/own_scales/make_phenix_q_weight.sh $dark_model $dark_FC $Dark_3 $Light_3 "$cell" $res_high $res_low
makefigs $name3


rm -f all_sc1.mtz all_sc2_free.mtz all_sc2.mtz dark_phase.hkl dark_scaled.hkl FC_dark.mtz Light_dark.phs Light_dwt.mtz light_scaled.hkl Light_wd.map model_phs.hkl scale_it.mtz wmar.inp
  
rm -f all_Fs.hkl all.mtz Fext_map.dat Fext_map.hkl fmodel fobs_dark fobs_light Fxt_map_9.map James_ext.mtz LFs_tmp1  light_Fs light_Fs_scaled light_Fs_scaled.hkl light.hkl neg_9.log  neg.inp neg_int.dat phenix_Fobs_Fobs.mtz tmp_dark_1 tmp_dark_12a tmp_dark_1a tmp_dark_2 tmp_dark_2a tmp_dark_phase_1  tmp_dark_phase_12a tmp_dark_phase_1a  tmp_dark_phase_2 tmp_dark_phase_2a tmp_light_1  tmp_light_12a tmp_light_1a tmp_light_2 tmp_light_2a weighted_map_log 
rm -f dark_Fs dark_Fs_scaled dark_Fs_scaled.hkl dark.hkl  dark_phases dark_phases.hkl dark_phases_sorted.hkl dFC_DFs_LFs_tmp1 dFC_DFs_LFs_tmp2 dFC_DFs_tmp1  dFC_tmp1 DFs_tmp1 diff_unweighted_map.dat diff_unweighted_map.hkl diff_unweighted_map.map diff_unweighted_map.mtz diff_weight_map.dat diff_weight_map.hkl diff_weight_map.mtz map_mol.ccp4 py_tmp.pml neg_*.log

