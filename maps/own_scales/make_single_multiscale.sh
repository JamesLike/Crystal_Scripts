#!/bin/bash
loc="/home/james/PycharmProjects/Crystal_Scripts/maps"
#J Baxter 2020
SYMM=" 19"
if [  "X$#" == "X2" ] ; then
	cell=$1
	add=$2
else
	echo "Usage: maps_single_multiscale <cell> "
	exit 1
fi
echo "Making single multiscale phenix map at "${add}
python ${loc}/own_scales/extended_map.py $add
rm Fext_map.dat
awk '{printf "%5i%5i%5i%12.3f%12.3f%12.3f \n",$1, $2, $3, $4, $5, $6}' Fext_unw_map.dat > Fext_unw_map.hkl #hkl phFC Fext, sigFext
################
# Turn the extended hkls into mtz
################
f2mtz HKLIN Fext_unw_map.hkl HKLOUT Ext_unw_phenix_multiscale_${add}.mtz >log << end_weight
CELL ${cell}
SYMM ${SYMM}
LABOUT H   K  L   PHI  Fext  sigFext
CTYPE  H   H  H   P      F   Q
END
end_weight