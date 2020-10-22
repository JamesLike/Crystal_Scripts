unset normalize_ccp4_maps
map_double map, -1
isomesh neg, map_mol, -3, all
isomesh pos, map_mol, 3, all
color magenta, neg
color marine, pos
util.cbay
show sticks
set stick_radius=0.15
set mesh_width=0.25
set mesh_quality=1
load /home/james/data/crystallography/JvT81/Cryo_Structures/Maps_3/0.pdb
show sticks, 0
set_view (\
     0.351513892,    0.931560338,   -0.092833631,\
    -0.807464540,    0.251511246,   -0.533596337,\
    -0.473731458,    0.262532830,    0.840619087,\
    -0.000045031,   -0.000002389,  -32.115291595,\
    -3.356009960,    7.618175507,  -20.740978241,\
    26.761615753,   37.516529083,  -20.000000000 )
bg_color white
ray 800,600
png png.png

set_view (\
     0.549213529,    0.185837895,    0.814746082,\
     0.171616182,    0.929086864,   -0.327603668,\
    -0.817858338,    0.319751680,    0.478383571,\
     0.000000000,    0.000000000,  -21.146800995,\
    -5.602000237,    3.663000107,  -24.591999054,\
    15.769344330,   26.524257660,  -20.000000000 )
bg_color white
ray 800,600
png png1.png

set_view (\
     0.962443769,   -0.189082906,    0.194770277,\
     0.245642111,    0.301279098,   -0.921341062,\
     0.115536034,    0.934592307,    0.336414814,\
     0.000022557,   -0.000385761,  -30.254915237,\
     0.699131489,    7.467167377,  -24.001482010,\
    25.114200592,   35.495605469,  -20.000000000 )
bg_color white
ray 800,600
png png2.png
