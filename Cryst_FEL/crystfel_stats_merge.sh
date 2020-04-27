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
Number_images=$(/dls/i24/data/2020/mx19458-39/processing/crystFEL/store/indexed_filenames  *.stream | wc -l)

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
echo "-Cutting"
# cut -c 84-90       $FILENAME_SNR    >$TEMP_RES
cut -c 38-44       $FILENAME_CCstar     >$TEMP_RES
cut -c 29-36,39-59 $FILENAME_SNR    >$TEMP_SNR
cut -c 14-22       $FILENAME_RSPLIT >$TEMP_RSPLIT
cut -c 13-22       $FILENAME_CCstar     >$TEMP_CCstar
cut -c 13-22       $FILENAME_CC     >$TEMP_CC
grep "^Number of crystals:" -A 20 $FILENAME_LOG | grep -B 20 " total  (" | tail -n +2  >$FILENAME_OUT
echo >>$FILENAME_OUT

grep "first hit: "  $FILENAME_LOG   >>$FILENAME_OUT
grep "last hit: "   $FILENAME_LOG   >>$FILENAME_OUT
echo >>$FILENAME_OUT

echo "overall Compl. = $OVERALL_COMPLETENESS   (measured $SUM_MEASURED of $SUM_POSSIBLE reflections)"             >>$FILENAME_OUT
echo "Total number of Crystals: $Number_images " >>$FILENAME_OUT
echo "overall Red.   = $OVERALL_REDUNDANCY   ($NUM_TOTAL_MEAS measurements of $NUM_TOTAL_REFL reflections)"       >>$FILENAME_OUT
grep "^overall "                  $FILENAME_LOG | sed -e 's| <snr> = | <snr>  = |g'                               >>$FILENAME_OUT
grep "^Overall "                  $FILENAME_LOG | sed -e 's|Overall |overall |g' | sed -e 's| CC\* = | CC*    = |g' >>$FILENAME_OUT
#grep "Overall CC"  $FILENAME_LOG >> $FILENAME_OUT
grep "B =" wilson.dat >> $FILENAME_OUT
echo >>$FILENAME_OUT
paste -d " " $TEMP_RES $TEMP_SNR $TEMP_RSPLIT $TEMP_CC $TEMP_CCstar                               >>$FILENAME_OUT
cp $FILENAME_OUT "Stats_summary.log"
echo "-Done"
rm $TEMP_RSPLIT $TEMP_CC $TEMP_RES $TEMP_SNR

