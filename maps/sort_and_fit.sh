#!/bin/bash
#J Baxter 2020

for d in */; do
	cd ./$d
	echo $d
	mkdir dat
	mv * dat
	a=$(phenix.python /mnt/data4/XFEL/LR23/DED_tests/scripts/N_ext_fit_conv_2.py dat/neg_unw_count.dat | awk '{print int($3)}')
	echo $a
	if [ $a -gt 0 ]; then
		if [ $a -lt 40 ]; then
		b=$(($a*10+1))
		echo $b
		cp dat/Fxt_unw_${b}.mtz .
		mv N_ext_Fitted_C.png ../${d}.png
		fi
	fi
	cd ..
done
	
