#!/bin/bash
# J. Baxter - Will take a stream and high res cut, calculate relevent stats and comine them in to a file (called ~stats summary)
if [ "X$#" == "X2" ]; then
	echo "Starting processing.."
	STREAM_FILENAME=$1
	HIGHRES=$2
else
	echo "Usage: crystfel_make_hkl_and_stats <streamfile> <high resolution cut> "
	exit 1
fi
#########################
# Edits here:
#########################
CELL_FILENAME="/mnt/data11/LR23_part/table1_stats/cell.cell"  #  "/dls/i24/data/2020/mx19458-39/processing/crystFEL/store/rsKiiro_refined.cell"
POINTGROUP="mmm"
#SPACEGROUP="P212121"
#cell=" 39.60 74.44 78.92" # pH8 400
PROCESSHKL_OPTIONS=" --scale --push-res=0.5"
loc="/mnt/data11/LR23_part" # This should be pointing to the directory of crystfel_stats_merge.sh no need for a / to follow/m

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
FILES_BASENAME=$(echo $STREAM_FILENAME | sed -e "s|.stream$||g" )
FILES_BASENAME_2=$(echo $FILES_BASENAME'_2')
HKL_FILENAME="${FILES_BASENAME}.hkl"
TMP_HKL_FILENAME="${FILES_BASENAME_2}.temp.hkl"
MTZ_FILENAME="${FILES_BASENAME}.mtz"
MTZ_FILENAME_TRUN="${FILES_BASENAME}_truncate.mtz"
MERGING_LOGFNAME="${FILES_BASENAME}_merging.log"
PROCESSING_LOGFNAME="${FILES_BASENAME}_${HIGHRESTAG}_processing.log"

#########################
# Ambigator (if needed)
#########################
#echo "Running Ambigator.."
#ambigator $STREAM_FILENAME -o  -y 321_H --operator=-h,-k,l --fg-graph=fg.dat -j 7 --lowres=10 --highres=2.10 --ncorr=1000
#ambigator  $STREAM_FILENAME -o detwinned_${STREAM_FILENAME} -y 3m1_H -w 6mm --fg-graph=fg.dat -j 7 --lowres=5 --highres=3
#ambigator  $STREAM_FILENAME -o detwinned_${STREAM_FILENAME} -y 3m1_H -w 6mm --fg-graph=fg.dat -j 7 --lowres=12 --highres=3
#cp $STREAM_FILENAME detwinned_${STREAM_FILENAME}
#echo "Ambigator complete.."
#echo "Plotting.."
#~/progs/crystfel-0.8.0/scripts/fg-graph fg.da
#echo "Plotting Complete.."

#########################
# Process hkl (options defined above)
#########################
#echo "Running process_hkl..."
#process_hkl -i ${STREAM_FILENAME} -o ${HKL_FILENAME}   -y $POINTGROUP $PROCESSHKL_OPTIONS 2>&1 | tee $MERGING_LOGFNAME
#process_hkl -i ${STREAM_FILENAME} -o ${HKL_FILENAME}_o -y $POINTGROUP $PROCESSHKL_OPTIONS --odd-only
#process_hkl -i ${STREAM_FILENAME} -o ${HKL_FILENAME}_e -y $POINTGROUP $PROCESSHKL_OPTIONS --even-only
#rm -f $MTZ_FILENAME
#rm -f $TMP_HKL_FILENAME
#########################
# Partialtor hkl (options defined above)
#########################
partialator -i ${STREAM_FILENAME} -o ${HKL_FILENAME} -y mmm --model=unity --iterations=3 -j 7

mv ${HKL_FILENAME}1 ${HKL_FILENAME}_o
mv ${HKL_FILENAME}2 ${HKL_FILENAME}_e


#########################
# Gerneate
#########################

check_hkl   ${HKL_FILENAME}     -y $POINTGROUP -p $CELL_FILENAME --highres=$HIGHRES --shell-file=${FILES_BASENAME}_SNR_${HIGHRESTAG}.dat    >>$PROCESSING_LOGFNAME 2>&1
check_hkl   ${HKL_FILENAME}     -y $POINTGROUP -p $CELL_FILENAME --highres=$HIGHRES --shell-file=${FILES_BASENAME}_WILSON_${HIGHRESTAG}.dat --wilson   >>wilson.dat 2>&1
echo >>$PROCESSING_LOGFNAME
echo "Running compare_hkl..."
compare_hkl ${HKL_FILENAME}_o ${HKL_FILENAME}_e -y $POINTGROUP -p $CELL_FILENAME --fom=rsplit --highres=$HIGHRES --shell-file=${FILES_BASENAME}_Rsplit_${HIGHRESTAG}.dat >>$PROCESSING_LOGFNAME 2>&1
echo >>$PROCESSING_LOGFNAME
compare_hkl ${HKL_FILENAME}_o ${HKL_FILENAME}_e -y $POINTGROUP -p $CELL_FILENAME --fom=ccstar --highres=$HIGHRES --shell-file=${FILES_BASENAME}_CCstar_${HIGHRESTAG}.dat     >>$PROCESSING_LOGFNAME 2>&1
compare_hkl ${HKL_FILENAME}_o ${HKL_FILENAME}_e -y $POINTGROUP -p $CELL_FILENAME --fom=cc --highres=$HIGHRES --shell-file=${FILES_BASENAME}_CC_${HIGHRESTAG}.dat     >>$PROCESSING_LOGFNAME 2>&1
echo >>$PROCESSING_LOGFNAME

#########################
# Place all stats in a file..
# Need to have other script somewhere sensible! (crystfel_stats_merge.sh)
#########################
echo "Combining statistics..."
${loc}/crystfel_stats_merge.sh ${FILES_BASENAME}_Rsplit_${HIGHRESTAG}.dat


#########################
# Gernerate and truncate data..
#########################
#OUTFILE=`echo ${HKL_FILENAME} | sed -e 's/\.hkl$/.mtz/'`
#echo "Making hkl"
#echo ${HKL_FILENAME}
#sed -n '/End\ of\ reflections/q;p' ${HKL_FILENAME} > create-mtz.temp.hkl
#echo "Made hkl"



#echo "Running 'f2mtz'..."
#f2mtz HKLIN create-mtz.temp.hkl HKLOUT $OUTFILE > out.html << EOF
#TITLE Reflections from CrystFEL
#NAME PROJECT wibble CRYSTAL wibble DATASET wibble
#CELL ${cell}
#SYMM 19
#SKIP 3
#LABOUT H K L IMEAN SIGIMEAN
#CTYPE  H H H J     Q
#FORMAT '(3(F4.0,1X),F10.2,10X,F10.2)'
#EOF
#
#if [ $? -ne 0 ]; then echo "Failed."; exit; fi
#
#rm -f create-mtz.temp.hkl
#echo "Done."
#
#echo "now running ctruncate"
#truncate HKLIN $OUTFILE HKLOUT ${HIGHRES}_${MTZ_FILENAME_TRUN} > truncate.log << EOF
#truncate     YES
#anomalous     NO
#resolution 78.900 $HIGHRES
#contents     H 1705     C 1128     N 304     O 328     S 10
#plot     OFF
#header BRIEF BATCH
#labin IMEAN=IMEAN SIGIMEAN=SIGIMEAN
#falloff     yes     cone 30.0     PLTX
#NOHARVEST
#end
#EOF




echo
echo "crystfel_make_hkl_and_stats finished sucessfully."
echo
mkdir dat
mkdir streams
mv *stream streams
mv *.hkl* dat
mv *.dat dat
#mv *merging* dat
#mv *.png dat
#mv *.log dat
#mv *.html dat
#mv dat/*statsummary* .
#echo " Number of crystals:" >> *statsummary* && number_indexed_images streams/detwinned_${STREAM_FILENAME} >> *statsummary*
rm PLOT
