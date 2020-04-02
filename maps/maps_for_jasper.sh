#!/bin/bash
#LR23
dark_model="/mnt/data4/XFEL/LR23/DED_tests/dat/Dark.pdb"
dark_FC="/mnt/data4/XFEL/LR23/DED_tests/dat/dark_F_SFALL_calc.mtz"
#dark_obs="/mnt/data4/XFEL/LR23/DED_tests/testing/AllRuns-mosflm_total_dark_new_truncate3.mtz "
dark_obs="/mnt/data4/XFEL/LR23/DED_tests/testing/AllRuns-mosflm_total_dark_phenix_massage.mtz"

#2019a
dark_model="/mnt/data4/XFEL/SACLA/dark-iso_refmac5.pdb"
dark_FC="/mnt/data4/XFEL/SACLA/dark_SFALL_calc.mtz"
#dark_obs="/mnt/data4/XFEL/SACLA/dark_new_truncate.mtz" 
dark_obs="/mnt/data4/XFEL/SACLA/dark_phenix_mas.mtz"

#dark_model="/mnt/data4/serial/2019_05_p14/processing/q_weighted/q_weighted_EXT_New_FC_rescut_2/dark.pdb"
#dark_model="/mnt/data4/serial/2019_05_p14/processing/q_weighted/q_weighted_EXT_New_FC_rescut_Backwards/light.pdb"

#dark_FC="/mnt/data4/serial/2019_05_p14/processing/q_weighted/q_weighted_EXT_New_FC_rescut_2/dark_Fs.mtz"
#dark_FC="/mnt/data4/serial/2019_05_p14/processing/q_weighted/q_weighted_EXT_New_FC_rescut_Backwards/light.mtz"



#dark_obs="/mnt/data4/XFEL/LR23/DED_tests/testing/tmp_truncate1.mtz" 
#dark_obs="/mnt/data4/serial/2019_05_p14/processing/q_weighted/00_phenix_massage_RES_CUT.mtz"
#dark_obs="/mnt/data4/serial/2019_05_p14/processing/q_weighted/q_weighted_EXT_New_FC_rescut_Backwards/12_0_phenix_massage.mtz"
#
#dark_model="/mnt/data4/serial/2019_05_p14/processing/q_weighted/q_weighted_EXT_New_FC_2/dark_single.pdb" 
#dark_FC="/mnt/data4/serial/2019_05_p14/processing/q_weighted/q_weighted_EXT_New_FC_2/dark_single.mtz" 
#dark_obs="/mnt/data4/serial/2019_05_p14/processing/q_weighted/00_phenix_massage_RES_CUT.mtz" 
##
#39.440   74.190   78.840  90.00  90.00  90.00 
#dark_model="/mnt/NAS/Personal/Jamesb/DATA-SACLA-2019A/dat/dark-iso_refmac5.pdb"
#dark_FC="/mnt/NAS/Personal/Jamesb/DATA-SACLA-2019A/dat/dark_new_truncate_refmac.mtz"
#dark_obs="/mnt/NAS/Personal/Jamesb/DATA-SACLA-2019A/dat/dark_new_truncate.mtz"
#cell=' 39.440   74.190   78.840  90.00  90.00  90.00 '
#cell=" 39.60  74.50  78.90  90.00  90.00  90.00"
#cell=" 39.60  74.50  78.90  90.00  90.00  90.00"
#cell=" 39.340  74.010  78.620  90.00  90.00  90.00" #LR23 Cell
cell=" 39.440  74.190  78.840  90.00  90.00  90.00" #2019a cell
##
resmax=1.5 #1.70
resmin=15

if [ ! -f $dark_model ]; then
    echo "$dark_model not found!"
    exit 1
else if [ ! -f $dark_FC ]; then
    echo "$dark_FC not found!"
    exit 1
else if [ ! -f $dark_obs ]; then
    echo "$dark_obs not found!"
    exit 1
fi
fi
fi

cp $dark_model .
cp $dark_obs .
cp $dark_FC .
work_dir=$(echo | pwd)

FILES=*.hkl
for f in $FILES
do
  cd $work_dir
  name=$(echo  | basename $f .hkl)
  echo "Processing $name "
  mkdir $name 
  cd $name
  cp ../$f .
  echo "Dark Obs:"$dark_model > map.log
  /mnt/data4/XFEL/LR23/DED_tests/scripts/trunc_all_options.sh $f $resmax $resmin "$cell"
  /mnt/data4/XFEL/LR23/DED_tests/scripts/map_generate.sh $dark_model $dark_FC $dark_obs ./${name}_phenix_massage.mtz $name $resmax 15 "$cell">>map.log
  /mnt/data4/XFEL/LR23/DED_tests/scripts/own_scales/make_phenix_q_weight.sh $dark_model $dark_FC $dark_obs ./${name}_phenix_massage.mtz "$cell"
#  /mnt/data4/XFEL/LR23/DED_tests/scripts/map_generate.sh $dark_model $dark_FC $dark_obs ./${name}_new_truncate.mtz $name $resmax 15 "$cell" >>map.log
#  /mnt/data4/XFEL/LR23/DED_tests/scripts/own_scales/make_phenix_q_weight.sh $dark_model $dark_FC $dark_obs ./${name}_new_truncate.mtz "$cell"
  /mnt/data4/XFEL/LR23/DED_tests/scripts/Extrap_maps_marius.sh "$cell"
  phenix.python /mnt/data4/XFEL/LR23/DED_tests/scripts/N_ext_fit_conv.py neg_count_Mari.dat
  mv N_ext_Fitted_C.png count_MS.png
#  phenix.python /mnt/data4/XFEL/LR23/DED_tests/scripts/N_ext_fit_conv.py neg_count_Mari_1.dat
#  mv N_ext_Fitted_C.png count_MS_1.png
#  phenix.python /mnt/data4/XFEL/LR23/DED_tests/scripts/N_ext_fit_conv.py neg_count_Mari_2.dat
#  mv N_ext_Fitted_C.png count_MS_2.png
#  phenix.python /mnt/data4/XFEL/LR23/DED_tests/scripts/N_ext_fit_conv.py neg_count_Mari_3.dat
#  mv N_ext_Fitted_C.png count_MS_3.png

  a=$(phenix.python /mnt/data4/XFEL/LR23/DED_tests/scripts/N_ext_fit_conv_2.py neg_unw_count.dat | awk '{print int($3)}')
  b=$(($a*10+1))
  cp Fxt_unw_${b}.mtz ../UW_EXT_${name}.mtz
  mv N_ext_Fitted_C.png count_unw.png
  cp count_unw.png ../UW_${name}.png
  phenix.python /mnt/data4/XFEL/LR23/DED_tests/scripts/N_ext_fit_conv_2.py neg_count.dat
  mv N_ext_Fitted_C.png count_JB.png
  cp N_ext_Fitted_C.png ../${name}.png
  mv diff_weight_map.map ${name}_James_QW.map
  

  
  rm all_sc1.mtz all_sc2_free.mtz all_sc2.mtz dark_phase.hkl dark_scaled.hkl FC_dark.mtz Light_dark.phs Light_dwt.mtz light_scaled.hkl Light_wd.map model_phs.hkl scale_it.mtz wmar.inp
  mv Light_nonw.map ${name}_nonw.map
  mv Light_wdex.map ${name}_wdex.map
  
  echo load ${dark_model} > py_tmp.pml
  cp ${name}_wdex.map map_mol.ccp4
  echo load map_mol.ccp4 >> py_tmp.pml
  cat /mnt/data4/XFEL/LR23/DED_tests/scripts/view_map.pml >> py_tmp.pml
  pymol -c ./py_tmp.pml
  mv png.png ${name}_wdex.png

  echo load ${dark_model} > py_tmp.pml
  cp ${name}_phenix_multiscale_1.ccp4 map_mol.ccp4
  echo load map_mol.ccp4 >> py_tmp.pml
  cat /mnt/data4/XFEL/LR23/DED_tests/scripts/view_map.pml >> py_tmp.pml
  pymol -c ./py_tmp.pml
  mv png.png ${name}_phenix_multiscale.png
  
  echo load ${dark_model} > py_tmp.pml
  cp ${name}_James_QW.map map_mol.ccp4
  echo load map_mol.ccp4 >> py_tmp.pml
  cat /mnt/data4/XFEL/LR23/DED_tests/scripts/view_map.pml >> py_tmp.pml
  pymol -c ./py_tmp.pml
  mv png.png ${name}_James_QW.png

#rm all_Fs.hkl all.mtz Fext_map.dat Fext_map.hkl fmodel fobs_dark fobs_light Fxt_map_9.map James_ext.mtz LFs_tmp1  light_Fs light_Fs_scaled light_Fs_scaled.hkl light.hkl neg_9.log  neg.inp neg_int.dat phenix_Fobs_Fobs.mtz tmp_dark_1 tmp_dark_12a tmp_dark_1a tmp_dark_2 tmp_dark_2a tmp_dark_phase_1  tmp_dark_phase_12a tmp_dark_phase_1a  tmp_dark_phase_2 tmp_dark_phase_2a tmp_light_1  tmp_light_12a tmp_light_1a tmp_light_2 tmp_light_2a weighted_map_log 
#rm dark_Fs dark_Fs_scaled dark_Fs_scaled.hkl dark.hkl  dark_phases dark_phases.hkl dark_phases_sorted.hkl dFC_DFs_LFs_tmp1 dFC_DFs_LFs_tmp2 dFC_DFs_tmp1  dFC_tmp1 DFs_tmp1 diff_unweighted_map.dat diff_unweighted_map.hkl diff_unweighted_map.map diff_unweighted_map.mtz diff_weight_map.dat diff_weight_map.hkl diff_weight_map.mtz map_mol.ccp4 py_tmp.pml neg_*.log

done

