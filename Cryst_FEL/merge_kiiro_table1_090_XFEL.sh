#!/bin/bash
# J. Baxter - Will take a stream and high res cut, calculate relevent stats and comine them in to a file (called ~stats summary)
if [ "X$#" == "X1" ]; then
	echo "Starting processing.."
	HKL_ROOT=$1
	#HIGHRES=$2
else
	echo "Usage: crystfel_make_hkl_and_stats <hkl> "
	exit 1
fi
#########################
# Edits here:
#########################
CELL_FILENAME="/home/james/data/crystallography/2020_PAL/jvt81_3.cell"
POINTGROUP="mmm"
HIGHRES=1.7
HIGHRES2=1.65
HIGHRES3=1.6
cp "${HKL_ROOT}_o" ${HKL_ROOT}1
cp "${HKL_ROOT}_e" ${HKL_ROOT}2

#SPACEGROUP="P212121"
#cell=" 39.60 74.44 78.92" # pH8 400

loc="${HOME}/PycharmProjects/Crystal_Scripts/" # This should be pointing to the directory of crystfel_stats_merge.sh no need for a / to follow

#########################
#Check files exist and make some names..
#########################
if [ ! -f $CELL_FILENAME ] ; then
    echo "ERROR: $CELL_FILENAME does not exist."
    exit 1
fi
HIGHRESTAG=$(echo "${HIGHRES}A" | sed -e "s|\.|p|g" )
HIGHRESTAG2=$(echo "${HIGHRES2}A" | sed -e "s|\.|p|g" )
HIGHRESTAG3=$(echo "${HIGHRES3}A" | sed -e "s|\.|p|g" )


FILES_BASENAME=$(basename ${HKL_ROOT} .hkl)
HKL_FILENAME=$HKL_ROOT
PROCESSING_LOGFNAME="${FILES_BASENAME}_${HIGHRESTAG}_processing.log"
PROCESSING_LOGFNAME2="${FILES_BASENAME}_${HIGHRESTAG2}_processing.log"
PROCESSING_LOGFNAME3="${FILES_BASENAME}_${HIGHRESTAG3}_processing.log"


#########################
# Hkls x 3 res limits
#########################

check_hkl   ${HKL_FILENAME}     -y $POINTGROUP -p $CELL_FILENAME --highres=$HIGHRES --shell-file=${FILES_BASENAME}_SNR_${HIGHRESTAG}.dat    >>$PROCESSING_LOGFNAME 2>&1
check_hkl   ${HKL_FILENAME}     -y $POINTGROUP -p $CELL_FILENAME --highres=$HIGHRES --shell-file=${FILES_BASENAME}_WILSON_${HIGHRESTAG}.dat --wilson   >>$PROCESSING_LOGFNAME 2>&1
echo >>$PROCESSING_LOGFNAME
echo "Running compare_hkl..."
compare_hkl ${HKL_FILENAME}1 ${HKL_FILENAME}2 -y $POINTGROUP -p $CELL_FILENAME --fom=rsplit --highres=$HIGHRES --shell-file=${FILES_BASENAME}_Rsplit_${HIGHRESTAG}.dat >>$PROCESSING_LOGFNAME 2>&1
echo >>$PROCESSING_LOGFNAME
compare_hkl ${HKL_FILENAME}1 ${HKL_FILENAME}2 -y $POINTGROUP -p $CELL_FILENAME --fom=ccstar --highres=$HIGHRES --shell-file=${FILES_BASENAME}_CCstar_${HIGHRESTAG}.dat     >>$PROCESSING_LOGFNAME 2>&1
compare_hkl ${HKL_FILENAME}1 ${HKL_FILENAME}2 -y $POINTGROUP -p $CELL_FILENAME --fom=cc --highres=$HIGHRES --shell-file=${FILES_BASENAME}_CC_${HIGHRESTAG}.dat     >>$PROCESSING_LOGFNAME 2>&1
echo >>$PROCESSING_LOGFNAME

#check_hkl   ${HKL_FILENAME}     -y $POINTGROUP -p $CELL_FILENAME --highres=$HIGHRES2 --shell-file=${FILES_BASENAME}_SNR_${HIGHRESTAG2}.dat    >>$PROCESSING_LOGFNAME2 2>&1
#check_hkl   ${HKL_FILENAME}     -y $POINTGROUP -p $CELL_FILENAME --highres=$HIGHRES2 --shell-file=${FILES_BASENAME}_WILSON_${HIGHRESTAG2}.dat --wilson   >>$PROCESSING_LOGFNAME2 2>&1
#echo >>$PROCESSING_LOGFNAME2
#echo "Running compare_hkl..."
#compare_hkl ${HKL_FILENAME}1 ${HKL_FILENAME}2 -y $POINTGROUP -p $CELL_FILENAME --fom=rsplit --highres=$HIGHRES2 --shell-file=${FILES_BASENAME}_Rsplit_${HIGHRESTAG2}.dat >>$PROCESSING_LOGFNAME2 2>&1
#echo >>$PROCESSING_LOGFNAME2
#compare_hkl ${HKL_FILENAME}1 ${HKL_FILENAME}2 -y $POINTGROUP -p $CELL_FILENAME --fom=ccstar --highres=$HIGHRES2 --shell-file=${FILES_BASENAME}_CCstar_${HIGHRESTAG2}.dat     >>$PROCESSING_LOGFNAME2 2>&1
#compare_hkl ${HKL_FILENAME}1 ${HKL_FILENAME}2 -y $POINTGROUP -p $CELL_FILENAME --fom=cc --highres=$HIGHRES2 --shell-file=${FILES_BASENAME}_CC_${HIGHRESTAG2}.dat     >>$PROCESSING_LOGFNAME2 2>&1
#echo >>$PROCESSING_LOGFNAME2
#
#check_hkl   ${HKL_FILENAME}     -y $POINTGROUP -p $CELL_FILENAME --highres=$HIGHRES3 --shell-file=${FILES_BASENAME}_SNR_${HIGHRESTAG3}.dat    >>$PROCESSING_LOGFNAME3 2>&1
#check_hkl   ${HKL_FILENAME}     -y $POINTGROUP -p $CELL_FILENAME --highres=$HIGHRES3 --shell-file=${FILES_BASENAME}_WILSON_${HIGHRESTAG3}.dat --wilson   >>$PROCESSING_LOGFNAME3 2>&1
#echo >>$PROCESSING_LOGFNAME3
#echo "Running compare_hkl..."
#compare_hkl ${HKL_FILENAME}1 ${HKL_FILENAME}2 -y $POINTGROUP -p $CELL_FILENAME --fom=rsplit --highres=$HIGHRES3 --shell-file=${FILES_BASENAME}_Rsplit_${HIGHRESTAG3}.dat >>$PROCESSING_LOGFNAME3 2>&1
#echo >>$PROCESSING_LOGFNAME3
#compare_hkl ${HKL_FILENAME}1 ${HKL_FILENAME}2 -y $POINTGROUP -p $CELL_FILENAME --fom=ccstar --highres=$HIGHRES3 --shell-file=${FILES_BASENAME}_CCstar_${HIGHRESTAG3}.dat     >>$PROCESSING_LOGFNAME3 2>&1
#compare_hkl ${HKL_FILENAME}1 ${HKL_FILENAME}2 -y $POINTGROUP -p $CELL_FILENAME --fom=cc --highres=$HIGHRES3 --shell-file=${FILES_BASENAME}_CC_${HIGHRESTAG3}.dat     >>$PROCESSING_LOGFNAME3 2>&1
#echo >>$PROCESSING_LOGFNAME3
#########################
# Place all stats in a file..
# Need to have other script somewhere sensible! (crystfel_stats_merge.sh)
#########################
echo "Combining statistics..."
~/PycharmProjects/Crystal_Scripts/Cryst_FEL/merge_kiiro_table1_063_XFEL.sh ${FILES_BASENAME}_Rsplit_${HIGHRESTAG}.dat
#~/PycharmProjects/Crystal_Scripts/Cryst_FEL/merge_kiiro_table1_063_XFEL.sh ${FILES_BASENAME}_Rsplit_${HIGHRESTAG2}.dat
#~/PycharmProjects/Crystal_Scripts/Cryst_FEL/merge_kiiro_table1_063_XFEL.sh ${FILES_BASENAME}_Rsplit_${HIGHRESTAG3}.dat

echo
echo "crystfel_make_hkl_and_stats finished sucessfully."
echo
#"Table1_"$(echo  $FILENAME_RSPLIT | sed -e 's/_Rsplit_//g' )

TABLE1="Table1_"${FILES_BASENAME}${HIGHRESTAG}.dat
TABLE2="Table1_"${FILES_BASENAME}${HIGHRESTAG2}.dat
TABLE3="Table1_"${FILES_BASENAME}${HIGHRESTAG3}.dat

T1_RES=$(grep 'Res' $TABLE1 | awk '{print $4, $5}')
T1_REF=$(grep 'No. Un' $TABLE1 | awk '{print $5}')
T1_MREF=$(grep 'No. Mer' $TABLE1 | awk '{print $4, $5}')
T1_COMP=$(grep 'Compl' $TABLE1 | awk '{print $3, $4}')
T1_SNR=$(grep 'Sig' $TABLE1 | awk '{print $4, $5}')
T1_WIL=$(grep 'Wils' $TABLE1 | awk '{print $5}')
T1_RSPL=$(grep 'Split' $TABLE1 | awk '{print $3,$4}')
T1_CC=$(grep 'CC\* ' $TABLE1 | awk '{print $2,$3}')
T1_CC5=$(grep 'CC\$' $TABLE1 | awk '{print $2,$3}')
#


#T1_RES=$(grep 'Res' $TABLE1 | awk '{print $4, $5}')"a"
#T1_REF=$(grep 'No. Un' $TABLE1 | awk '{print $5}')"a"
#T1_MREF=$(grep 'No. Mer' $TABLE1 | awk '{print $4, $5}')"a"
#T1_COMP=$(grep 'Compl' $TABLE1 | awk '{print $3, $4}')"a"
#T1_SNR=$(grep 'Sig' $TABLE1 | awk '{print $4, $5}')"a"
#T1_WIL=$(grep 'Wils' $TABLE1 | awk '{print $5}')"a"
#T1_RSPL=$(grep 'Split' $TABLE1 | awk '{print $3,$4}')"a"
#T1_CC=$(grep 'CC\* ' $TABLE1 | awk '{print $2,$3}')"a"
#T1_CC5=$(grep 'CC\$' $TABLE1 | awk '{print $2,$3}')"a"
##
#T2_RES=$(grep 'Res' $TABLE2 | awk '{print $4, $5}')"b"
#T2_REF=$(grep 'No. Un' $TABLE2 | awk '{print $5}')"b"
#T2_MREF=$(grep 'No. Mer' $TABLE2 | awk '{print $4, $5}')"b"
#T2_COMP=$(grep 'Compl' $TABLE2 | awk '{print $3, $4}')"b"
#T2_SNR=$(grep 'Sig' $TABLE2 | awk '{print $4, $5}')"b"
#T2_WIL=$(grep 'Wils' $TABLE2 | awk '{print $5}')"b"
#T2_RSPL=$(grep 'Split' $TABLE2 | awk '{print $3,$4}')"b"
#T2_CC=$(grep 'CC\* ' $TABLE2 | awk '{print $2,$3}')"b"
#T2_CC5=$(grep 'CC\$' $TABLE2 | awk '{print $2,$3}')"b"
#
#T3_RES=$(grep 'Res' $TABLE3 | awk '{print $4, $5}')"c"
#T3_REF=$(grep 'No. Un' $TABLE3 | awk '{print $5}')"c"
#T3_MREF=$(grep 'No. Mer' $TABLE3 | awk '{print $4, $5}')"c"
#T3_COMP=$(grep 'Compl' $TABLE3 | awk '{print $3, $4}')"c"
#T3_SNR=$(grep 'Sig' $TABLE3 | awk '{print $4, $5}')"c"
#T3_WIL=$(grep 'Wils' $TABLE3 | awk '{print $5}')"c"
#T3_RSPL=$(grep 'Split' $TABLE3 | awk '{print $3,$4}')"c"
#T3_CC=$(grep 'CC\* ' $TABLE3 | awk '{print $2,$3}')"c"
#T3_CC5=$(grep 'CC\$' $TABLE3 | awk '{print $2,$3}')"c"

name=$(basename $HKL_ROOT .hkl | sed -e "s/AllllRuns-mosflm_fs-//g")
TABLE0="${name}.table"
#images=$( grep $name /home/james/data/crystallography/LCLS_LR23/old_crystfel_proc_hkl/LCLS_logs/results-tags.txt | awk -F ':' '{print $2}')
#images=$(cat "${name}-process-log.txt"  | grep 'cryst' | head -n 1 | awk '{print $6}')
images=$(grep 'Begin cry' ../streams/*.stream | wc -l)

#echo -e "Name:                          \t $name"   >$TABLE0
#echo -e "Indexed Patterns:              \t $images" >>$TABLE0
#echo -e "Resolution Limits \AA:         \t $T1_RES" >>$TABLE0
#echo -e "                               \t $T2_RES" >>$TABLE0
#echo -e "                               \t $T3_RES" >>$TABLE0
#echo -e "No. Unique reflection Indicies:\t $T1_REF" >>$TABLE0
#echo -e "                               \t $T2_REF" >>$TABLE0
#echo -e "                               \t $T3_REF" >>$TABLE0
#echo -e "No. Merged   Reflections:      \t $T1_MREF">>$TABLE0
#echo -e "                               \t $T2_MREF">>$TABLE0
#echo -e "                               \t $T3_MREF">>$TABLE0
#echo -e "Completeness (%):              \t $T1_COMP">>$TABLE0
#echo -e "                               \t $T2_COMP">>$TABLE0
#echo -e "                               \t $T3_COMP">>$TABLE0
#echo -e "Signal to noise:               \t $T1_SNR" >>$TABLE0
#echo -e "                               \t $T2_SNR" >>$TABLE0
#echo -e "                               \t $T3_SNR" >>$TABLE0
#echo -e "Wilson b factor:               \t $T1_WIL" >>$TABLE0
#echo -e "                               \t $T2_WIL" >>$TABLE0
#echo -e "                               \t $T3_WIL" >>$TABLE0
#echo -e "R\$_{Split}\$ (%):             \t $T1_RSPL">>$TABLE0
#echo -e "                               \t $T2_RSPL">>$TABLE0
#echo -e "                               \t $T3_RSPL">>$TABLE0
#echo -e "CC*                            \t $T1_CC"  >>$TABLE0
#echo -e "                               \t $T2_CC"  >>$TABLE0
#echo -e "                               \t $T3_CC"  >>$TABLE0
#echo -e "CC\$_{1/2}\$                   \t $T1_CC5" >>$TABLE0
#echo -e "                               \t $T2_CC5" >>$TABLE0
#echo -e "                               \t $T3_CC5" >>$TABLE0

echo -e "Name:                          \t $name" >$TABLE0
echo -e "Indexed Patterns:              \t $images" >>$TABLE0
echo -e "Resolution Limits \AA:         \t $T1_RES" >>$TABLE0
echo -e "No. Unique reflection Indicies:\t $T1_REF" >>$TABLE0
echo -e "No. Merged   Reflections:      \t $T1_MREF">>$TABLE0
echo -e "Completeness (%):              \t $T1_COMP">>$TABLE0
echo -e "Signal to noise:               \t $T1_SNR" >>$TABLE0
echo -e "Wilson b factor:               \t $T1_WIL" >>$TABLE0
echo -e "R\$_{Split}\$ (%):             \t $T1_RSPL">>$TABLE0
echo -e "CC*                            \t $T1_CC"  >>$TABLE0
echo -e "CC\$_{1/2}\$                   \t $T1_CC5" >>$TABLE0




#mkdir dat
#mkdir streams
#mv *stream streams
#mv *.hkl* dat
#mv *.dat dat
#mv *merging* dat
#mv *.png dat
#mv *.log dat
#mv *.html dat
#mv dat/*statsummary* .
#echo " Number of crystals:" >> *statsummary* && number_indexed_images streams/detwinned_${STREAM_FILENAME} >> *statsummary*
rm -f PLOT