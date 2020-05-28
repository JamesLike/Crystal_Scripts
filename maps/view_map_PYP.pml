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
set_view (\
     0.453579307,    0.585590363,   -0.671814859,\
    -0.890610337,    0.325432569,   -0.317632616,\
     0.032629102,    0.742405951,    0.669142425,\
     0.000000000,    0.000000000,  -48.389339447,\
    -3.664000034,    6.857999802,  -19.878999710,\
    43.011878967,   53.766799927,  -20.000000000 )
bg_color white
ray 1000,1000
png png.png