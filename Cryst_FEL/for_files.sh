#!/bin/bash
directory="/home/james/data/crystallography/2020_PAL/experiement/merged/"

#for filename in $directory/* ; do
#	echo 'Processing.. ' $filename
#	#cd $filename
#	#mv ./streams/*.stream .
#	#/dls/i24/data/2020/mx19458-39/processing/crystFEL/store/merge_kiiro_partial.sh *.stream 1.75
#
#	#cd ./dat
#	#cp ../*processing.log .
#	~/PycharmProjects/Crystal_Scripts/Cryst_FEL/crystfel_stats_merge.sh *Rsplit*.dat
#	name=$(basename $filename)
#	sed -i "1s/^/	${name}\n/" Table1.dat
#	cp Table1.dat ../../${name}.dat
#	cd ..
#	cd ..
#done

for filename in ${directory}*_d* ; do
	name=${filename}"/laser-off/laser-off.stream"
	echo 'Processing.. ' "$name"
	base=$(basename $filename)
	echo 'Processing.. ' "$base"
  grep 'Cell pa' $name | awk '{print $3, $4, $5, $7, $8, $9}' > cells.dat
  python ~/PycharmProjects/Crystal_Scripts/Cryst_FEL/unit_cell.py cells.dat $base
  #rm -f cells.dat
done


#!/bin/bash
#directory="/dls/x05-1/data/2020/mx15722-24/processing/cheetah_proc/cheetah/hdf5/"

#for filename in $directory/* ; do
#	echo 'Processing.. ' $filename
#	#cd $filename
#	#mv ./streams/*.stream .
#	#/dls/i24/data/2020/mx19458-39/processing/crystFEL/store/merge_kiiro_partial.sh *.stream 1.75
#
#	#cd ./dat
#	#cp ../*processing.log .
#	~/PycharmProjects/Crystal_Scripts/Cryst_FEL/crystfel_stats_merge.sh *Rsplit*.dat
#	name=$(basename $filename)
#	sed -i "1s/^/	${name}\n/" Table1.dat
#	cp Table1.dat ../../${name}.dat
#	cd ..
#	cd ..
#done
#
#for filename in ${directory}*v3* ; do
#	echo 'Processing.. ' "$filename"
#	base=(basenme $filename)
#	/dls/x05-1/data/2020/mx15722-24/processing/crystfel_proc/jvt_run_1.sh "$filename"
#done