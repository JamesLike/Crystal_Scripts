#!/bin/bash

coords="/home/jb2717/Documents/Crystallography/JvT81/OCC/omit.pdb"
#coords="/home/jb2717/Documents/Crystallography/JvT75/OCC/files/omit.pdb"
if [ "X$#" == "X1" ] ; then
	mtz="$1"
	F_lab="F"
	sig_F="SIGF"
	free="FreeR_flag"
	coords_chrom='/home/jb2717/Documents/Crystallography/JvT81/OCC/chrom.pdb'
else
if [ "X$#" == "X2" ] ; then
	mtz="$1"
	image_name="$2"
	F_lab="F"
	sig_F="SIGF"
	free="FREER"
	coords_chrom='/home/jb2717/Documents/Crystallography/JvT81/OCC/chrom.pdb'
else
	echo "Usage: <mtz filename> (image name) will then make maps using weighted differneces by doing a single rigid body refinement using ${coords} as coordinates"
	exit 1
fi
fi

map="map"
map_mol="map_mol"
mtz_out="ref.mtz"
pdb_out="ref.pdb"

echo "Starting Omit map maker.. "
echo "Starting Refmac.. "

refmac5 HKLIN $mtz HKLOUT ${mtz_out} XYZOUT ${pdb_out} XYZIN ${coords}  >log << eop
make check NONE
make     hydrogen ALL     hout NO     peptide NO     cispeptide YES     ssbridge YES     symmetry YES     sugar YES     connectivity NO     link NO
refi     type RIGID     resi MLKF     meth CGMAT     bref over
rigid ncycle 1
scal     type SIMP     LSSC     ANISO     EXPE
solvent YES
weight     AUTO
monitor MEDIUM     torsion 10.0     distance 10.0     angle 10.0     plane 10.0     chiral 10.0     bfactor 10.0     bsphere 10.0     rbond 10.0     ncsr 10.0
labin FP=${F_lab} SIGFP=${sig_F} # FREE=${free}
#labin FP=F_100ps SIGFP=SIGF_100ps FREE=FreeR_flag #FREE=FREER
labout  FC=FC FWT=FWT PHIC=PHIC PHWT=PHWT DELFWT=DELFWT PHDELWT=PHDELWT FOM=FOM
DNAME SAD
END
eop

echo "Refmac done.. "
###################################################################
#  Calculate the difference map for an asymmetric unit
###################################################################
echo "Making map.."
fft hklin ${mtz_out} mapout ${map} >>log <<eof-fft
	LABIN   F1=DELFWT PHI=PHDELWT
	END
eof-fft
echo "extending map.."
###################################################################
#  Extend the difference map to cover the molecule + 4 Ang
###################################################################

mapmask mapin ${map} mapout ${map_mol}  \
   xyzin ${coords} >>log <<eof-mapmask
	border 4
        mode mapin
eof-mapmask
echo "Shrinking coordinates.. "
phenix.pdbtools ${pdb_out} keep="chain 1 and resid 64 or chain 2 and resid 64" >>log
echo "Running pymol.. "
pymol -c ~/scripts/omit_view.pml >pymol_log
mv png.png ${image_name}.png
# CLean up
mkdir "${image_name}_OMIT"
mv pymol_log ${image_name}
mv "${map}.map" ${image_name}
mv ${mtz_out} ${image_name}
mv ref.mmcif ${image_name}
mv log ${image_name}
mv $pdb_out $image_name
mv ref.pdb_modified.pdb ${image_name}
mv ref.pdb_modified.cif ${image_name}
mv ${map_mol}.map ${image_name}
