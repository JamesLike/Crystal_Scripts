#!/bin/bash
directory=$(pwd)

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

for filename in $directory/*.hkl ; do
	echo 'Processing.. ' $filename
	../merge_kiiro_stats_prep.sh $filename 1.45
done