#!/bin/bash
loc="/home/james/PycharmProjects/Crystal_Scripts/maps"
#J Baxter 2020
# Need to choose somewhere for sphere...
obs_map="./neg_map.map"
xc=-3.66
yc=6.86
zc=-19.88

radius=5 #4 #8.0
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
