#!/bin/bash
#LR23
#dark_model="/mnt/data4/XFEL/LR23/DED_tests/dat/Dark.pdb"

#2019a
#dark_model="/mnt/data4/XFEL/SACLA/dark-iso_refmac5.pdb"

#dark_model="/mnt/data4/serial/2019_05_p14/processing/q_weighted/q_weighted_EXT_New_FC_rescut_2/dark.pdb"
#dark_model="/mnt/data4/serial/2019_05_p14/processing/q_weighted/q_weighted_EXT_New_FC_rescut_Backwards/light.pdb"
#dark_FC="/mnt/data4/serial/2019_05_p14/processing/q_weighted/q_weighted_EXT_New_FC_rescut_2/dark_Fs.mtz"
#dark_FC="/mnt/data4/serial/2019_05_p14/processing/q_weighted/q_weighted_EXT_New_FC_rescut_Backwards/light.mtz"

#dark_model="/mnt/data4/serial/2019_05_p14/processing/q_weighted/q_weighted_EXT_New_FC_2/dark_single.pdb" 
#dark_FC="/mnt/data4/serial/2019_05_p14/processing/q_weighted/q_weighted_EXT_New_FC_2/dark_single.mtz" 
#dark_obs="/mnt/data4/serial/2019_05_p14/processing/q_weighted/00_phenix_massage_RES_CUT.mtz" 

dark_obs="something"
dark_model="somethig"
trunc_type="_phenix_massage.mtz"
#trunc_type="_new_truncate.mtz"

loc="/home/james/scripts/diff_maps" #script location, no need for trailing /
res_high=1.75 #Highest resolution term eg 1.3
res_low=50 #Lowest resolution term eg 15
SYMM=19 # Symmetry group eg P212121 or 19

if [ ! -f $dark_model ]; then echo "$dark_model not found!" && exit 1 ; fi
if [ ! -f $dark_obs ]; then echo "$dark_obs not found!" && exit 1; fi
if [ ! -d $loc ]; then echo "$loc not found!" && exit 1 ; fi

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
	png_name=$(echo $1 | sed -e 's/\.map$//')
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
#Go to the PDB file and look up the cell
######################################
cell=$(${loc}/pdb_cell.sh $dark_model)
if [ -z "$cell" ]; then echo "Your cell is empty !" && exit 1 ; fi

######################################
# Generate Fc from the dark model
######################################
${loc}/generate_FC.sh $dark_model $SYMM
dark_FC=$(echo $dark_model | sed -e 's/\.pdb$/_SFALL.mtz/')

######################################
# Generate Fo from the dark Is
# Then do some organisation
######################################
/mnt/data4/XFEL/LR23/DED_tests/scripts/trunc_all_options.sh $dark_obs $res_high $res_low "$cell"
cp $dark_model .
cp $dark_obs .
cp $dark_FC .
work_dir=$(echo | pwd)

######################################
# Start the processing loop for all
# hkl files in the dir
######################################
FILES=*.hkl
for f in $FILES
do
  cd $work_dir || exit
  name=$(echo  | basename $f .hkl)
  echo "Processing $name "
  mkdir $name
  cd $name || exit
  cp ../$f .
  echo "Dark Obs:"$dark_model > map.log
  ######################################
  ## Convert the dark Is to Fs
  ## Make all the maps
  ## Make the phenix maps and extrapolated
  ## Make the scalit extrap maps
  ######################################
  ${loc}/trunc_all_options.sh $f $res_high $res_low "$cell"
  ${loc}/map_generate.sh $dark_model $dark_FC $dark_obs ./${name}${trunc_type} $name $res_high $res_low "$cell" >> map.log
  ${loc}/make_phenix_q_weight.sh $dark_model $dark_FC $dark_obs ./${name}${trunc_type} "$cell"
  ${loc}/Extrap_maps_marius.sh "$cell"

  ######################################
  ## Fit the extraolated maps
  ######################################
  phenix.python ${loc}/N_ext_fit_conv.py neg_count_Mari.dat
  mv N_ext_Fitted_C.png count_MS.png
  phenix.python ${loc}/N_ext_fit_conv_2.py neg_unw_count.dat
  mv N_ext_Fitted_C.png count_unw.png
  phenix.python ${loc}/N_ext_fit_conv_2.py neg_count.dat
  mv N_ext_Fitted_C.png count_JB.png
#  a=$(phenix.python ${loc}/N_ext_fit_conv_2.py neg_unw_count.dat | awk '{print int($3)}')
#  b=$(($a*10+1))
  ######################################
  ## Move some stuff
  ## Make pymol figures
  ######################################
  move ${name}
  makefigs ${name}_wdex.map
  makefigs_${name}_phenix_multiscale_1.ccp4
  makefigs ${name}_James_QW.map

  ######################################
  # Clean up
  ######################################

  rm -f all_sc1.mtz all_sc2_free.mtz all_sc2.mtz dark_phase.hkl dark_scaled.hkl FC_dark.mtz Light_dark.phs Light_dwt.mtz light_scaled.hkl Light_wd.map model_phs.hkl scale_it.mtz wmar.inp
  #rm all_Fs.hkl all.mtz Fext_map.dat Fext_map.hkl fmodel fobs_dark fobs_light Fxt_map_9.map James_ext.mtz LFs_tmp1  light_Fs light_Fs_scaled light_Fs_scaled.hkl light.hkl neg_9.log  neg.inp neg_int.dat phenix_Fobs_Fobs.mtz tmp_dark_1 tmp_dark_12a tmp_dark_1a tmp_dark_2 tmp_dark_2a tmp_dark_phase_1  tmp_dark_phase_12a tmp_dark_phase_1a  tmp_dark_phase_2 tmp_dark_phase_2a tmp_light_1  tmp_light_12a tmp_light_1a tmp_light_2 tmp_light_2a weighted_map_log
  #rm dark_Fs dark_Fs_scaled dark_Fs_scaled.hkl dark.hkl  dark_phases dark_phases.hkl dark_phases_sorted.hkl dFC_DFs_LFs_tmp1 dFC_DFs_LFs_tmp2 dFC_DFs_tmp1  dFC_tmp1 DFs_tmp1 diff_unweighted_map.dat diff_unweighted_map.hkl diff_unweighted_map.map diff_unweighted_map.mtz diff_weight_map.dat diff_weight_map.hkl diff_weight_map.mtz map_mol.ccp4 py_tmp.pml neg_*.log
done

