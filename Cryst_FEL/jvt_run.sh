#!/bin/bash
#Want to make directory, list the images, correct the images names and link them
# EDIT this script for the geometry analyasis - it copies and then generates sa load of data so be carefiul!
module load CrystFEL
#export PATH=/dls/science/users/mep23677/modules/crystfel/bin:$PATH

if [ "X$#" == "X1" ] ; then
        RUN_NAME="$1"
        #IMAGE_PATH="$2"
	      #GEOM="$3"
else
        echo "Usage: <name> Will then tak the geometry file and edot the clength / run crystfel with nww clength"
        exit 1
fi



Proc_DIR="/dls/x05-1/data/2020/mx15722-24/processing/crystfel_proc/1/"
STORE="/dls/x05-1/data/2020/mx15722-24/processing/store/"
CELL="${STORE}jvt81_3.cell"
GEOM="${STORE}rayonix-mx225hs-4x_1909_1.geom"

#IMAGE_PATH="/mnt/data3/*$RUN_NAME*/"
IMAGE_PATH="/dls/x05-1/data/2020/mx15722-24/processing/cheetah_proc/cheetah/hdf5/${RUN_NAME}/"

if [ ! -f $CELL ]; then echo "$CELL not found!" && exit 1 ; fi
if [ ! -f $GEOM ]; then echo "$GEOM not found!" && exit 1 ; fi
if [ ! -d $IMAGE_PATH ]; then echo " $IMAGE_PATH img not found!" && exit 1 ; fi
if [ ! -d $Proc_DIR ]; then echo " $Proc_DIR not found!" && exit 1 ; fi

if [ -d "$RUN_NAME" ]; then echo "Directory already exists.. Baking up and continuing"
        mv "$RUN_NAME" "$RUN_NAME.bak"
fi
echo "Moving to " $Proc_DIR
cd $Proc_DIR || exit
mkdir "$RUN_NAME"
cd "$RUN_NAME"/ || exit

echo "Making image directory!"
ln -s $IMAGE_PATH images

ls images/*.cxi > images.lst
cp $GEOM .
#cp ${STORE}images.lst .
#sed -i "s/pXX/p${RUN_NAME}/g" images.lst
#cp /home/jb2717/scripts/crystfel_kiiro_RUN .
echo "Starting to index.."

#indexamajig -i images.lst -g $GEOM --multi --peaks=zaef --threshold=20 --min-gradien=100 --min-snr=3 --indexing=xgandalf --int-radius=3,4,5  -o ${RUN_NAME}.stream -p $CELL -j 20 2>&1 | tee crystfel.log
#got rid of multi
indexamajig -i images.lst -g $GEOM --multi --peaks=cxi --threshold=20 --min-gradien=100 --min-snr=3 --indexing=xgandalf --int-radius=3,4,5  -o ${RUN_NAME}.stream -p $CELL -j 20 2>&1 | tee crystfel.log

# Then do the laser sortin!
module load python/3.8
${STORE}/sort_Pumplaser_pal.py ${CXI file}
${STORE}sort_streams_AF.py ${RUN_NAME}.stream

mv LaserOn.stream ${RUN_NAME}_laser_on.stream
echo "----- Begin geometry file -----" > ${RUN_NAME}_laser_off.stream
cat $GEOM >> ${RUN_NAME}_laser_off.stream
echo "----- End geometry file -----" >> ${RUN_NAME}_laser_off.stream
echo "----- Begin unit cell -----" >> ${RUN_NAME}_laser_off.stream
cat $CELL >> ${RUN_NAME}_laser_off.stream
echo "----- End unit cell -----" >> ${RUN_NAME}_laser_off.stream
cat Laser_Off.stream >>  ${RUN_NAME}_laser_off.stream

rm Laser_Off.stream
echo "Done"
pwd




