#!/bin/bash
loc="/home/james/PycharmProjects/Crystal_Scripts/maps"
#J Baxter 2020
if [ ! -d $loc ]; then echo "$loc not found!" && exit 1 ; fi
SYMM=" 19"
if [  "X$#" == "X2" ] ; then
	cell=$1
	add=$2
	bin_nam="Light"
else
	echo "Usage: extrap_maps <cell> <extrap_value> (should be used after map_dmap... has been run)"
	exit 1
fi


echo "Making extrapmap of:" $add
echo dark_phase.hkl >  add.inp # Dark phases on an absolute scale hkl F sig F phase
echo ${bin_nam}_dark.phs >> add.inp # Q weighted time-point map: hkl deltF FOM PHI
echo light_scaled.hkl >> add.inp #  Light scaled structure factors hkl F sigF
echo darkFC_extrap.hkl >> add.inp
echo darkFC_extrap.phs >> add.inp
echo ${add} >> add.inp
${loc}/progs/fc+fwv3 < add.inp

f2mtz HKLIN darkFC_extrap.hkl HKLOUT Ext_QW_SCALEIT_$add.mtz >log << end_weight
CELL ${cell}
SYMM ${SYMM}
LABOUT H   K  L   Fext  sigF  PHI
CTYPE  H   H  H   F     Q    P
END
end_weight

