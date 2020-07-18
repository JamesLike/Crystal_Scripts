#!/bin/bash
loc="/home/james/PycharmProjects/Crystal_Scripts/maps"
#J Baxter 2020
if [ ! -d $loc ]; then echo "$loc not found!" && exit 1 ; fi
SYMM=" 154"
bin_nam="Light"

if [  "X$#" == "X3" ] ; then
	dark_model=$1
	cell=$(${loc}/pdb_cell.sh $dark_model)
	res_high=$2
	res_low=$3
else
	echo "Usage: extrap_maps <pdb> <res_high> <res_low> (should be used after map_dmap... has been run) MAKE SURE TO UPDATE SYM AT THE TOP OF THIS SCRIPT!"
	exit 1
fi

if [ ! -f $dark_model ]; then echo "$dark_model not found!" && exit 1 ; fi
rm -f neg_add.dat add.dat

added=1
while [ $added -le 100 ]
do
	add=$(echo "scale=2; $added/10" | bc -l)
	echo "Processing " $add
	echo dark_phase.hkl >  add.inp # Dark phases on an absolute scale hkl F sig F phase
	echo ${bin_nam}_dark.phs >> add.inp # Q weighted time-point map: hkl deltF FOM PHI
	echo light_scaled.hkl >> add.inp #  Light scaled structure factors hkl F sigF
	echo darkFC_extrap.hkl >> add.inp
	echo darkFC_extrap.phs >> add.inp
	echo ${add} >> add.inp
	${loc}/progs/fc+fwv3 < add.inp

  f2mtz HKLIN darkFC_extrap.hkl HKLOUT marius_ext.mtz >log << end_weight
  CELL ${cell}
  SYMM ${SYMM}
  LABOUT H   K  L   Fext  sigF  PHI
  CTYPE  H   H  H   F     Q    P
  END
end_weight

  fft HKLIN marius_ext.mtz MAPOUT neg_map.map  >log << END-wfft
  RESO $res_low $res_high
  SCALE F1 1.0 0.0
  GRID 160 160 140
  BINMAPOUT
  LABI F1=Fext SIG1=sigF PHI=PHI
END-wfft
	${loc}/progs/neg_OCP.sh > neg_${add}_Mari.log
	grep 'SUM NEGATIVE DENSITY :' neg_${add}_Mari.log | awk '{print $5}' >> neg_add.dat
	echo $add >> add.dat
  mv marius_ext.mtz Fext_QW_SCALEIT_${added}.mtz
  mv neg_map.map Fext_QW_SCALEIT_${added}.map
  added=$(( $added + 5))
done

######################################
# Combine all the data together & plot
######################################
paste add.dat neg_add.dat > neg_count_Mari.dat
#gnuplot -e "set terminal png size 800,600; set output 'count_Mari.png'; set xlabel 'N_{EXT}'; set ylabel 'Integrated negative electron density (arb.)'; set key off ; plot 'neg_count_Mari.dat' using 1:(\$2*-1) with linespoints"
#rm Fext_map*
