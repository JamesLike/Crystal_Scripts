#!/bin/bash
#Want to make directory, list the images, correct the images names and link them
module load CrystFEL
#export PATH=/dls/science/users/mep23677/modules/crystfel/bin:$PATH

if [ "X$#" == "X3" ] ; then
        CHIP_NO="$1"
        IMAGE_PATH="$2"
	      GEOM="$3"
else
        echo "Usage: <name> <image_path> and  <geom>. Will then tak the geometry file and edot the clength / run crystfel with nww clength"
        exit 1
fi
Proc_DIR="/dls/x05-1/data/2020/mx15722-24/processing/james/detector_ref/2/"
cd $Proc_DIR

if [ -d "$CHIP_NO" ]; then
        echo "Directory already exists.. Baking up and conintuing"
        mv "$CHIP_NO" "$CHIP_NO.bak"
fi
if [ ! -d $GEOM ]; then echo "$GEOM not found!" && exit 1 ; fi


#IMAGE_PATH="/mnt/data3/*$CHIP_NO*/"
STORE="/dls/x05-1/data/2020/mx15722-24/processing/james/detector_ref/2/geoms/og"

CELL="${STORE}jvt81_2.cell"
#GEOM="${STORE}rayonix-mx225hs-4x_0004_EDITED_${clen}.geom"

mkdir "$CHIP_NO"
cd "$CHIP_NO"/
ln -s $IMAGE_PATH images
ls images/*.h5 > images.lst
cp $GEOM .
#cp ${STORE}images.lst .
#sed -i "s/pXX/p${CHIP_NO}/g" images.lst
#cp /home/jb2717/scripts/crystfel_kiiro_RUN .
echo "Starting to index.."

#indexamajig -i images.lst -g $GEOM --multi --peaks=zaef --threshold=20 --min-gradien=100 --min-snr=3 --indexing=xgandalf --int-radius=3,4,5  -o ${CHIP_NO}.stream -p $CELL -j 20 2>&1 | tee crystfel.log
#got rid of multi
indexamajig -i images.lst -g $GEOM --multi --peaks=zaef --threshold=20 --min-gradien=100 --min-snr=3 --indexing=xgandalf --int-radius=3,4,5  -o ${CHIP_NO}.stream -p $CELL -j 20 2>&1 | tee crystfel.log


echo "Done"
pwd


