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
    -0.532512307,    0.202533051,    0.821835935,\
     0.732288182,   -0.376694322,    0.567322791,\
     0.424480677,    0.903924406,    0.052281436,\
     0.000000000,    0.000000000,  -44.061656952,\
    43.636001587,   80.290000916,   97.850997925,\
    31.772739410,   56.350574493,  -20.000000000 )
bg_color white
ray 1000,1000
png png.png
