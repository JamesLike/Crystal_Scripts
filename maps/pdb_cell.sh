#! /bin/bash 

if [  "X$#" == "X1" ] ; then
	pdbfile=$1
else
    echo
    echo "Usage: <pdbfile> will then echo the cell dimensions of the pdb"
    echo
    exit 1
fi

if [ ! -f $pdbfile ]; then
    echo "$pdbfile not found!"
    exit 1
fi

CELL=`awk '/^CRYST1/{print $2,$3,$4,$5,$6,$7;exit}' $pdbfile`

echo $CELL
