#!/bin/bash
loc="/home/james/PycharmProjects/Crystal_Scripts/maps"
#J Baxter 2020
# Need to choose somewhere for sphere...
obs_map="./neg_map.map"
# Centreed on water:
#xc=-22.0
#yc=11.0
#zc=-3.0

#Centreted on N term caratanoid:
#xc=-20.0
#yc=19.0
#zc=10.0

# Edge of carat (close to MET117)
#13.69
#xc=-19.3
#yc=22.0
#zc=13.6

#Close to MET202
xc=-18.64
yc=0.162
zc=-13.61

#xc=
#yc=
#zc=

radius=5.0 #8.0 #4 #8.0
sigma=2  # 2 #2 #1.5
out_map=mask_1.map

echo $obs_map > neg.inp
echo $out_map >> neg.inp
echo 6  >> neg.inp # Number of symmetry operators
echo X,Y,Z >> neg.inp
echo -Y,X-Y,Z+2/3 >> neg.inp
echo -X+Y,-X,Z+1/3 >> neg.inp
echo Y,X,-Z >> neg.inp
echo X-Y,-Y,1/3-Z >> neg.inp
echo -X,-X+Y,2/3-Z >> neg.inp
echo $xc $yc $zc >> neg.inp # Centre of sphere
echo $radius >> neg.inp
echo $sigma >> neg.inp

${loc}/progs/NegExCCP4_v2 < neg.inp
