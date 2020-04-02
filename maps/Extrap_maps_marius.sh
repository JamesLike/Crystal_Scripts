#!/bin/bash
#J Baxter 2020

resmax=1.35
bin_nam="Light"

#space_group=" 38.6  73.8  78.1  90  90  90"
#space_group=" 39.60  74.50  78.90  90.00  90.00  90.00"
#space_group=" 39.34  74.01  78.62  90  90  90" #FEL
space_group=$1
SYMM=" 19"

rm neg_add.dat add.dat


added=1
while [ $added -le 300 ]
do
	add=$(echo "scale=2; $added/10" | bc -l)
	echo "Processing " $add
	echo dark_phase.hkl >  add.inp # Dark phases on an absolute scale hkl F sig F phase
	echo ${bin_nam}_dark.phs >> add.inp # Q weighted time-point map: hkl deltF FOM PHI
	echo light_scaled.hkl >> add.inp #  Light scaled structure factors hkl F sigF 
	echo darkFC_extrap.hkl >> add.inp
	echo darkFC_extrap.phs >> add.inp
	echo ${add} >> add.inp
	~/progs/marius/scripts/PROGS/fc+fwv3 < add.inp
	

f2mtz HKLIN darkFC_extrap.hkl HKLOUT marius_ext.mtz >log << end_weight 
#CELL 39.34  74.01  78.62  90  90  90  # angles default to 90
#SYMM 19
CELL${space_group}
SYMM${SYMM}
LABOUT H   K  L   Fext  sigF  PHI 
CTYPE  H   H  H   F     Q    P
END
end_weight

fft HKLIN marius_ext.mtz MAPOUT neg_map.map  >log << END-wfft 
RESO 15 $resmax
SCALE F1 1.0 0.0
GRID 160 160 140
BINMAPOUT
LABI F1=Fext SIG1=sigF PHI=PHI
END-wfft



	~/scripts/marius/neg_int/neg.sh > neg_${add}_Mari.log 
	grep 'SUM NEGATIVE DENSITY :' neg_${add}_Mari.log | awk '{print $5}' >> neg_add.dat

#	~/scripts/marius/neg_int/neg_1.sh > neg_${add}_Mari_1.log 
#	grep 'SUM NEGATIVE DENSITY :' neg_${add}_Mari_1.log | awk '{print $5}' >> neg_add_1.dat

#	~/scripts/marius/neg_int/neg_2.sh > neg_${add}_Mari_2.log 
#	grep 'SUM NEGATIVE DENSITY :' neg_${add}_Mari_2.log | awk '{print $5}' >> neg_add_2.dat

#	~/scripts/marius/neg_int/neg_3.sh > neg_${add}_Mari_3.log 
#	grep 'SUM NEGATIVE DENSITY :' neg_${add}_Mari_3.log | awk '{print $5}' >> neg_add_3.dat

	echo $add >> add.dat



mv marius_ext.mtz Fext_${added}.mtz
mv neg_map.map Fext_map_${added}_Mari.map

added=$(( $added + 5))
done

paste add.dat neg_add.dat > neg_count_Mari.dat
paste add.dat neg_add_1.dat > neg_count_Mari_1.dat
paste add.dat neg_add_2.dat > neg_count_Mari_2.dat
paste add.dat neg_add_3.dat > neg_count_Mari_3.dat

gnuplot -e "set terminal png size 800,600; set output 'count_Mari.png'; set xlabel 'N_{EXT}'; set ylabel 'Integrated negative electron density (arb.)'; set key off ; plot 'neg_count_Mari.dat' using 1:(\$2*-1) with linespoints"

#rm Fext_map*


