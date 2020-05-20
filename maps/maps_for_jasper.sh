#!/bin/bash
loc="/home/james/PycharmProjects/Crystal_Scripts/maps"
#J Baxter 2020
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

dark_obs="/mnt/data11/LR23_part/store/AllRuns-mosflm_total_dark.hkl"
dark_model="/mnt/data11/LR23_part/store/Dark.pdb"

#dark_obs="/home/james/Desktop/tmptmptmp/AllRuns-mosflm_total_dark.hkl"
#dark_model="/home/james/Desktop/tmptmptmp/Dark.pdb"


trunc_type="_phenix_massage.mtz"
#trunc_type="_new_truncate.mtz"

res_high=1.5 #Highest resolution term eg 1.3
res_low=30 #Lowest resolution term eg 15
SYMM=19 # Symmetry group eg P212121 or 19
clean="yes" #if you do not want to keep all the intermediate files
if [ ! -f $dark_model ]; then echo "$dark_model not found!" && exit 1 ; fi
if [ ! -f $dark_obs ]; then echo "$dark_obs not found!" && exit 1; fi
if [ ! -d $loc ]; then echo "$loc not found!" && exit 1 ; fi

######################################
#Quick Functions for later
######################################
move () {
  mv diff_weight_map.map "$1"_James_QW.map
	mv Light_nonw.map "$1"_nonw.map
	mv Light_wdex.map "$1"_wdex.map
}

pymolfig () {
	rm -f py_tmp.pml
	echo load ${dark_model} > py_tmp.pml
	cp $1 map_mol.ccp4
	echo load map_mol.ccp4 >> py_tmp.pml
	cat ${loc}/view_map_XFEL.pml >> py_tmp.pml
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

params () {
  echo "File: " $name
  echo "Dark Obs: " $dark_obs
  echo "Dark Model: " $dark_model
  echo "Space Group:" $SYMM
  echo "Unit Cell: " $cell
  echo "High Resolution cut:" $res_high
  echo "Low Resolution cut:" $res_low
  echo "Reflection Conversion:" $trunc_type
  echo "Negative Intergration:"
  grep -m1 xc ${loc}/progs/neg.sh
  grep -m1 yc= ${loc}/progs/neg.sh
  grep -m1 zc ${loc}/progs/neg.sh
  grep -m1 radius ${loc}/progs/neg.sh
  grep -m1 sigma ${loc}/progs/neg.sh
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
FILES=*.hkl
######################################
# Generate Fo from the dark Is
# Then do some organisation
######################################
cp $dark_obs .
${loc}/trunc_all_options.sh ${dark_obs##*/} $res_high $res_low "$cell"
rm ${dark_obs##*/}
cp $dark_model .
cp $dark_FC .
work_dir=$(echo | pwd)
dark_basename=$(echo | basename $dark_obs .hkl)
dark_OBS="../"${dark_basename}${trunc_type}
echo $dark_OBS
######################################
# Start the processing loop for all
# hkl files in the dir
######################################
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
  ${loc}/trunc_all_options.sh $f $res_high $res_low "$cell" || exit
  ${loc}/map_generate.sh $dark_model $dark_FC $dark_OBS ./${name}${trunc_type} $name $res_high $res_low "$cell" >> map.log || exit
  ${loc}/own_scales/make_phenix_q_weight.sh $dark_model $dark_FC $dark_OBS ./${name}${trunc_type} "$cell" $res_high $res_low|| exit
  ${loc}/extrap_maps_marius.sh "$cell" $res_high $res_low || exit

  ######################################
  ## Clean up is the clean option is y
  ######################################
  if [ "$clean" == "yes" ] ; then
   rm Fext_QW_SCALEIT*.mtz Fext_QW_SCALEIT*.map Fext_QW_Phenix_Multiscale_* Fext_unw_Phenix_Multiscale_*
  fi

  ######################################
  ## Fit the extraolated maps and gernate only the Next value calaulated
  ######################################
  Next1=$(phenix.python ${loc}/N_ext_fit_conv_2.py neg_count_Mari.dat | awk '{print $3}')
  mv N_ext_Fitted_C.png count_QW_Scaleit.png
  ${loc}/extrap_MS_call.sh "$cell" $Next1

  Next2=$(phenix.python ${loc}/N_ext_fit_conv_2.py neg_unw_count_Phenix.dat | awk '{print $3}')
  mv N_ext_Fitted_C.png count_unw_Phenix_Multiscale.png
  ${loc}/own_scales/make_single_multiscale.sh "$cell" $Next2

  Next3=$(phenix.python ${loc}/N_ext_fit_conv_2.py neg_count_Phenix.dat | awk '{print $3}')
  mv N_ext_Fitted_C.png count_QW_Phenix_multiscale.png
  ${loc}/own_scales/make_single_qw_multiscale.sh "$cell" $Next3
#  a=$(phenix.python ${loc}/N_ext_fit_conv_2.py neg_unw_count.dat | awk '{print int($3)}')
#  b=$(($a*10+1))
  ######################################
  ## Move some stuff
  ## Make pymol figures
  ######################################
  move "${name}"
  makefigs "${name}"

  ######################################
  # Clean up
  ######################################
  params > params.dat

  if [ "$clean" == "yes" ] ; then
    rm -f all_sc1.mtz all_sc2_free.mtz all_sc2.mtz dark_phase.hkl dark_scaled.hkl FC_dark.mtz Light_dark.phs Light_dwt.mtz light_scaled.hkl Light_wd.map model_phs.hkl scale_it.mtz wmar.inp
    rm -f all_Fs.hkl all.mtz Fext_map.dat Fext_map.hkl fmodel fobs_dark fobs_light Fxt_map_9.map James_ext.mtz LFs_tmp1  light_Fs light_Fs_scaled light_Fs_scaled.hkl light.hkl neg_9.log  neg.inp neg_int.dat phenix_Fobs_Fobs.mtz tmp_dark_1 tmp_dark_12a tmp_dark_1a tmp_dark_2 tmp_dark_2a tmp_dark_phase_1  tmp_dark_phase_12a tmp_dark_phase_1a  tmp_dark_phase_2 tmp_dark_phase_2a tmp_light_1  tmp_light_12a tmp_light_1a tmp_light_2 tmp_light_2a weighted_map_log
    rm -f dark_Fs dark_Fs_scaled dark_Fs_scaled.hkl dark.hkl  dark_phases dark_phases.hkl dark_phases_sorted.hkl dFC_DFs_LFs_tmp1 dFC_DFs_LFs_tmp2 dFC_DFs_tmp1  dFC_tmp1 DFs_tmp1 diff_unweighted_map.dat diff_unweighted_map.hkl diff_unweighted_map.map diff_unweighted_map.mtz diff_weight_map.dat diff_weight_map.hkl diff_weight_map.mtz map_mol.ccp4 py_tmp.pml neg_*.log
    rm -f add.dat COUNT.dat darkFC_extrap* FIT_C.dat neg_add.dat
  fi
done

