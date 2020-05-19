#!/bin/bash
# J. Baxter - Will take a stream and high res cut, calculate relevent stats and comine them in to a file (called ~stats summary)
if [ "X$#" == "X2" ]; then
	echo "Starting processing.."
	HKL_ROOT=$1
	HIGHRES=$2
else
	echo "Usage: crystfel_make_hkl_and_stats <streamfile> <high resolution cut> "
	exit 1
fi
#########################
# Edits here:
#########################
CELL_FILENAME="/mnt/data3/table1_stats/cell.cell"
POINTGROUP="mmm"
#SPACEGROUP="P212121"
#cell=" 39.60 74.44 78.92" # pH8 400

loc="." # This should be pointing to the directory of crystfel_stats_merge.sh no need for a / to follow

#########################
#Check files exist and make some names..
#########################
if [ ! -f $STREAM_FILENAME ] ; then
    echo "ERROR: $STREAM_FILENAME does not exist."
    exit 1
fi
if [ ! -f $CELL_FILENAME ] ; then
    echo "ERROR: $CELL_FILENAME does not exist."
    exit 1
fi
HIGHRESTAG=$(echo "${HIGHRES}A" | sed -e "s|\.|p|g" )
FILES_BASENAME=$(basename ${HKL_ROOT} .hkl)
#FILES_BASENAME_2=$(echo $FILES_BASENAME'_2')
HKL_FILENAME=$HKL_ROOT
PROCESSING_LOGFNAME="${FILES_BASENAME}_${HIGHRESTAG}_processing.log"


#########################
# Gerneate
#########################

check_hkl   ${HKL_FILENAME}     -y $POINTGROUP -p $CELL_FILENAME --highres=$HIGHRES --shell-file=${FILES_BASENAME}_SNR_${HIGHRESTAG}.dat    >>$PROCESSING_LOGFNAME 2>&1
check_hkl   ${HKL_FILENAME}     -y $POINTGROUP -p $CELL_FILENAME --highres=$HIGHRES --shell-file=${FILES_BASENAME}_WILSON_${HIGHRESTAG}.dat --wilson   >>wilson.dat 2>&1
echo >>$PROCESSING_LOGFNAME
echo "Running compare_hkl..."
compare_hkl ${HKL_FILENAME}1 ${HKL_FILENAME}2 -y $POINTGROUP -p $CELL_FILENAME --fom=rsplit --highres=$HIGHRES --shell-file=${FILES_BASENAME}_Rsplit_${HIGHRESTAG}.dat >>$PROCESSING_LOGFNAME 2>&1
echo >>$PROCESSING_LOGFNAME
compare_hkl ${HKL_FILENAME}1 ${HKL_FILENAME}2 -y $POINTGROUP -p $CELL_FILENAME --fom=ccstar --highres=$HIGHRES --shell-file=${FILES_BASENAME}_CCstar_${HIGHRESTAG}.dat     >>$PROCESSING_LOGFNAME 2>&1
compare_hkl ${HKL_FILENAME}1 ${HKL_FILENAME}2 -y $POINTGROUP -p $CELL_FILENAME --fom=cc --highres=$HIGHRES --shell-file=${FILES_BASENAME}_CC_${HIGHRESTAG}.dat     >>$PROCESSING_LOGFNAME 2>&1
echo >>$PROCESSING_LOGFNAME

#########################
# Place all stats in a file..
# Need to have other script somewhere sensible! (crystfel_stats_merge.sh)
#########################
echo "Combining statistics..."
../merge_kiiro_table1_xfel.sh ${FILES_BASENAME}_Rsplit_${HIGHRESTAG}.dat

echo
echo "crystfel_make_hkl_and_stats finished sucessfully."
echo
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
rm PLOT
