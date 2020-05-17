#!/bin/bash
# J. Baxter
if [ "X$1" == "X" -o ! -s "$1" ] ; then
    echo
    echo "Usage: crystfel_stats_merge <*_Rsplit_*.dat file>"
    echo
    exit 1
fi
echo "-Running CrystFEL_Stats_merge"
FILENAME_RSPLIT="$1"
FILENAME_CCstar=$(echo  $FILENAME_RSPLIT | sed -e 's/_Rsplit_/_CCstar_/g' )
FILENAME_CC=$(echo  $FILENAME_RSPLIT | sed -e 's/_Rsplit_/_CC_/g' )
FILENAME_SNR=$(echo $FILENAME_RSPLIT | sed -e 's/_Rsplit_/_SNR_/g' )
FILENAME_LOG=$(echo $FILENAME_RSPLIT | sed -e 's/_Rsplit_/_/g' | sed -e 's/A.dat$/A_processing.log/g' )
FILENAME_OUT=$(echo $FILENAME_RSPLIT | sed -e 's/_Rsplit_/_statsummary_/g' )
echo "-Making tmps "
TEMP_RSPLIT=$(mktemp -p /tmp mergestats_Rsplit.XXXXXXXXXX)
TEMP_CCstar=$(    mktemp -p /tmp mergestats_CCstar.XXXXXXXXXX)
TEMP_CC=$(    mktemp -p /tmp mergestats_CC.XXXXXXXXXX)
TEMP_RES=$(   mktemp -p /tmp mergestats_RES.XXXXXXXXXX)
TEMP_SNR=$(   mktemp -p /tmp mergestats_SNR.XXXXXXXXXX)

NUM_TOTAL_MEAS=$(grep " measurements in total.$" $FILENAME_LOG | sed -e 's| measurements in total.||g' )
NUM_TOTAL_REFL=$(grep " reflections in total.$"  $FILENAME_LOG | sed -e 's| reflections in total.||g' )
OVERALL_REDUNDANCY=$(printf "%.1f" $(echo $NUM_TOTAL_MEAS/$NUM_TOTAL_REFL | bc -l) )
Number_images=$(/dls/i24/data/2020/mx19458-39/processing/crystFEL/store/indexed_filenames  ../streams/*.stream | wc -l)

SUM_MEASURED=$(cut -b 11-20 $FILENAME_SNR | tail -n +2| tr '\n' '+' | sed -e 's|+$| \n|g' | bc -l )
SUM_POSSIBLE=$(cut -b 20-29 $FILENAME_SNR | tail -n +2| tr '\n' '+' | sed -e 's|+$| \n|g' | bc -l )

if [ "X$NUM_TOTAL_REFL" != "X$SUM_MEASURED" ] ; then
    echo "ERROR:"
    echo "ERROR: numbers don't match."
    echo "ERROR:"
    OVERALL_COMPLETENESS="-1.00"
else
    OVERALL_COMPLETENESS=$(printf "%.2f" $(echo 100*$SUM_MEASURED/$SUM_POSSIBLE | bc -l) )
fi

RES_LIMS=$(grep  "^Accepted" $FILENAME_LOG | head -1 | awk '{print $8"-"$10}')
RES_LIMS=${RES_LIMS#?}
H_RES_LIMS=$(tail $FILENAME_RSPLIT -n 1 | awk '{printf "%0.3f-%0.3f", 10/$5, 10/$6}')

sigtonoise=$(grep "^Overall <snr> " $FILENAME_LOG | awk '{printf "%0.3f", $4}')


rsplit=$(grep "^Overall Rsplit* " $FILENAME_LOG | awk '{printf "%0.2f", $4}')

ccstar=$(grep "^Overall CC\* " $FILENAME_LOG | awk '{printf "%0.2f", $4}')

cc=$(grep "^Overall CC " $FILENAME_LOG | awk '{printf "%0.2f", $4}')

wilsonb=$( grep "B =" wilson.dat | awk '{print $3}')


echo "-Cutting"
# cut -c 84-90       $FILENAME_SNR    >$TEMP_RES
cut -c 38-44       $FILENAME_CCstar     >$TEMP_RES
cut -c 29-36,39-59 $FILENAME_SNR    >$TEMP_SNR
cut -c 14-22       $FILENAME_RSPLIT >$TEMP_RSPLIT
cut -c 13-22       $FILENAME_CCstar     >$TEMP_CCstar
cut -c 13-22       $FILENAME_CC     >$TEMP_CC

#########################
# Now maps the combined output file
#########################
echo "overall Compl. = $OVERALL_COMPLETENESS   (measured $SUM_MEASURED of $SUM_POSSIBLE reflections)"             >>$FILENAME_OUT
echo "Total number of Crystals: $Number_images " >>$FILENAME_OUT
echo "overall Red.   = $OVERALL_REDUNDANCY   ($NUM_TOTAL_MEAS measurements of $NUM_TOTAL_REFL reflections)"       >>$FILENAME_OUT
grep "^overall "                  $FILENAME_LOG | sed -e 's| <snr> = | <snr>  = |g'                               >>$FILENAME_OUT
grep "^Overall "                  $FILENAME_LOG | sed -e 's|Overall |overall |g' | sed -e 's| CC\* = | CC*    = |g' >>$FILENAME_OUT
grep "Overall CC"  $FILENAME_LOG >> $FILENAME_OUT
grep "B =" wilson.dat >> $FILENAME_OUT
echo >>$FILENAME_OUT
paste -d " " $TEMP_RES $TEMP_SNR $TEMP_RSPLIT $TEMP_CC $TEMP_CCstar                               >>$FILENAME_OUT

TABLE1="Table1.dat"
hmeasured=$(tail $FILENAME_OUT -n 1 | awk '{printf "%0.0f", $3}')
hcomple=$(tail $FILENAME_OUT -n 1 | awk '{printf "%0.2f", $2}')
hsnr=$(tail $FILENAME_OUT -n 1 | awk '{printf "%0.2f", $5}')
hrsplit=$(tail $FILENAME_OUT -n 1 | awk '{printf "%0.2f", $6}')
hccstar=$(tail $FILENAME_OUT -n 1 | awk '{printf "%0.2f", $8}')
hcc=$(tail $FILENAME_OUT -n 1 | awk '{printf "%0.2f", $7}')


echo -e "Merged Crystals:               \t $Number_images "                       >$TABLE1
echo -e "No. Merged   Reflections:      \t $NUM_TOTAL_MEAS (${hmeasured})"        >>$TABLE1
echo -e "No. Unique reflection Indicies:\t $SUM_POSSIBLE "                        >>$TABLE1
echo -e "Resolution Limits \AA:         \t ${RES_LIMS} (${H_RES_LIMS})"           >>$TABLE1
echo -e "Completeness (%):              \t $OVERALL_COMPLETENESS (${hcomple})"    >>$TABLE1
echo "" >>$TABLE1
echo -e "CC\$_{1/2}\$                   \t $cc (${hcc})"                          >>$TABLE1
echo -e "R\$_{Split}\$ (%):             \t $rsplit (${hrsplit})"                  >>$TABLE1
echo -e "Signal to noise:               \t $sigtonoise (${hsnr})"                 >>$TABLE1
echo -e "Wilson b factor:               \t $wilsonb"                              >>$TABLE1
echo -e "CC*                            \t $ccstar (${hccstar})"                  >>$TABLE1



#echo -e "Resolution Limits \AA:         \t ${RES_LIMS} (${H_RES_LIMS})"           >$TABLE1
#echo -e "Merged Crystals:               \t $Number_images "                       >>$TABLE1
#echo -e "No. Unique reflection Indicies:\t $SUM_POSSIBLE "                        >>$TABLE1
#echo -e "No. Merged   Reflections:      \t $NUM_TOTAL_MEAS (${hmeasured})"        >>$TABLE1
#echo -e "Completeness (%):              \t $OVERALL_COMPLETENESS (${hcomple})"    >>$TABLE1
#echo -e "Signal to noise:               \t $sigtonoise (${hsnr})"                 >>$TABLE1
#echo -e "Wilson b factor:               \t $wilsonb"                              >>$TABLE1
#echo -e "R\$_{Split}\$ (%):             \t $rsplit (${hrsplit})"                  >>$TABLE1
#echo -e "CC*                            \t $ccstar (${hccstar})"                  >>$TABLE1
#echo -e "CC\$_{1/2}\$                   \t $cc (${hcc})"                          >>$TABLE1


cp $FILENAME_OUT "Stats_summary.log"
echo "-Done"
rm $TEMP_RSPLIT $TEMP_CC $TEMP_RES $TEMP_SNR

