unset normalize_ccp4_maps
map_double map, -1
hide all
isomesh neg, map_mol, -3, all, carve=2
isomesh pos, map_mol, 3, all, carve=2
color magenta, neg
color marine, pos
util.cbay
show cartoon
set stick_radius=0.15
set mesh_width=0.25
set mesh_quality=1
set_view (\
     0.068452738,    0.188427389,   -0.979692101,\
     0.724807024,    0.665389419,    0.178621918,\
     0.685540855,   -0.722316384,   -0.091025345,\
     0.000040770,    0.000021387, -140.905364990,\
   -22.695192337,    8.029335976,    0.020051003,\
    96.041603088,  185.744094849,  -20.000000000 )
bg_color white
ray 1000,1000
png png.png
