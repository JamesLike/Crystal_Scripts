#!/bin/bash
STREAM_FILENAME='/dls/x05-1/data/2020/mx15722-24/processing/james/stat-incrementing-lowres-cut/LASER_OFF.stream'
#CELL_FILENAME="/dls/x05-1/data/2020/mx15722-24/processing/store/jvt81_2.cell"
CELL_FILENAME="/dls/x05-1/data/2020/mx15722-24/processing/store/jvt81_3.cell"
POINTGROUP="mmm"
loc="/dls/x05-1/data/2020/mx15722-24/processing/store" # This should be pointing to the directory of crystfel_stats_merge.sh no need for a / to follow/m
HIGHRES="1.45"

if [ ! -f $STREAM_FILENAME ]; then echo "$STREAM_FILENAME not found!" && exit 1 ; fi
echo "Starting.."
number_crystals=$(grep 'Begin chunk' $STREAM_FILENAME | wc -l)
i=0
interval=$(($number_crystals/100))

CHECKHKL_OPTIONS=" --lowres=45"

#mkdir incre_proc
#cd incre_proc || exit
#rm -f counts.dat

echo "Will process from $i to $number_crystals in an interval of $interval"
echo "No. xtals" > overall_summary.dat
echo "<snr>" >> overall_summary.dat
echo "Redundancy" >> overall_summary.dat
echo "Completeness" >> overall_summary.dat
echo "R Split" >> overall_summary.dat
echo "CC*" >> overall_summary.dat
echo "CC" >> overall_summary.dat



while [ $i -le $number_crystals ]
#while [ $i -le 1500 ]
do
  rm -f Stats_summary.log
	i=$(($i+$interval))
	echo "Processing $i"
  PROCESSHKL_OPTIONS=" --scale --push-res=0.5 --stop-after $i"
  PROCESSHKL_OPTIONS2=" --scale --push-res=0.5 --stop-after $(($i/2))"

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

  echo "Running process_hkl..."
  process_hkl -i ${STREAM_FILENAME} -o ${HKL_FILENAME}   -y $POINTGROUP $PROCESSHKL_OPTIONS 2>&1 | tee $MERGING_LOGFNAME
  process_hkl -i ${STREAM_FILENAME} -o ${HKL_FILENAME}_o -y $POINTGROUP $PROCESSHKL_OPTIONS2 --odd-only
  process_hkl -i ${STREAM_FILENAME} -o ${HKL_FILENAME}_e -y $POINTGROUP $PROCESSHKL_OPTIONS2 --even-only
  rm -f $MTZ_FILENAME
  rm -f $TMP_HKL_FILENAME
  #########################
  # Partialtor hkl (options defined above)
  #########################
  #partialator -i ${STREAM_FILENAME} -o ${HKL_FILENAME} -y mmm --model=unity --iterations=3 -j 7
  #
  #mv ${HKL_FILENAME}1 ${HKL_FILENAME}_o
  #mv ${HKL_FILENAME}2 ${HKL_FILENAME}_e


  #########################
  # Gerneate
  #########################

  check_hkl   ${HKL_FILENAME} ${CHECKHKL_OPTIONS}    -y $POINTGROUP -p $CELL_FILENAME --highres=$HIGHRES --shell-file=${FILES_BASENAME}_SNR_${HIGHRESTAG}.dat    >>$PROCESSING_LOGFNAME 2>&1
  check_hkl   ${HKL_FILENAME} ${CHECKHKL_OPTIONS}    -y $POINTGROUP -p $CELL_FILENAME --highres=$HIGHRES --shell-file=${FILES_BASENAME}_WILSON_${HIGHRESTAG}.dat --wilson   >>wilson.dat 2>&1
  echo >>$PROCESSING_LOGFNAME
  echo "Running compare_hkl..."
  compare_hkl ${HKL_FILENAME}_o ${HKL_FILENAME}_e ${CHECKHKL_OPTIONS} -y $POINTGROUP -p $CELL_FILENAME --fom=rsplit --highres=$HIGHRES --shell-file=${FILES_BASENAME}_Rsplit_${HIGHRESTAG}.dat >>$PROCESSING_LOGFNAME 2>&1
  echo >>$PROCESSING_LOGFNAME
  compare_hkl ${HKL_FILENAME}_o ${HKL_FILENAME}_e ${CHECKHKL_OPTIONS} -y $POINTGROUP -p $CELL_FILENAME --fom=ccstar --highres=$HIGHRES --shell-file=${FILES_BASENAME}_CCstar_${HIGHRESTAG}.dat     >>$PROCESSING_LOGFNAME 2>&1
  compare_hkl ${HKL_FILENAME}_o ${HKL_FILENAME}_e ${CHECKHKL_OPTIONS} -y $POINTGROUP -p $CELL_FILENAME --fom=cc --highres=$HIGHRES --shell-file=${FILES_BASENAME}_CC_${HIGHRESTAG}.dat     >>$PROCESSING_LOGFNAME 2>&1
  echo >>$PROCESSING_LOGFNAME

  #########################
  # Place all stats in a file..
  # Need to have other script somewhere sensible! (crystfel_stats_merge.sh)
  #########################
  echo "Combining statistics..."
  ${loc}/crystfel_stats_merge.sh ${FILES_BASENAME}_Rsplit_${HIGHRESTAG}.dat



  echo
  echo "crystfel_make_hkl_and_stats finished sucessfully."
  echo
  #mv *merging* dat
  #mv *.png dat
  #mv *.log dat
  #mv *.html dat
  #mv dat/*statsummary* .
  #echo " Number of crystals:" >> *statsummary* && number_indexed_images streams/detwinned_${STREAM_FILENAME} >> *statsummary*
  rm PLOT
  ######################################
  echo $i > tmp_summary
  awk '{print $4}' Stats_summary.log | sed -n 5,10p >> tmp_summary
  paste overall_summary.dat tmp_summary > overall_summary.tmp
  mv overall_summary.tmp overall_summary.dat
  rm -f *.log *A.dat wilson.dat Table1.dat
done
rm overall_summary.tmp