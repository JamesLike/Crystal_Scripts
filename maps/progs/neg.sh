#!/bin/tcsh
#set obs_map = /home/jb2717/progs/marius/james/dat/test/occupancy_edits/maps/map_4.map
# sphere center for the double bond:
set obs_map = ./neg_map.map
# -1.49 5.38 -19.57
set xc = -3.66 #-2.205 #-2.77 #-1.74
set yc = 6.86 # 3.79 #6.59
set zc =  -19.88 # -19.73 #-20.16

set radius = 5 #4 #8.0
set sigma = 2  # 2 #2 #1.5
set out_map = mask_1.map

echo $obs_map > neg.inp
echo $out_map >> neg.inp
echo 4  >> neg.inp # Number of symmetry operators
echo X,Y,Z >> neg.inp
echo 1/2+X,1/2-Y,-Z >> neg.inp
echo -X,1/2+Y,1/2-Z >> neg.inp
echo 1/2-X,-Y,1/2+Z >> neg.inp
echo $xc $yc $zc >> neg.inp # Centre of sphere
echo $radius >> neg.inp
echo $sigma >> neg.inp

./NegExCCP4_v2 < neg.inp
