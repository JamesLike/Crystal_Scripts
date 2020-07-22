load pdb.pdb
load map_mol.ccp4
unset normalize_ccp4_maps
map_double map_mol, -1
hide all
isomesh neg, map_mol, -3.4, all, carve=2
isomesh pos, map_mol, 3.4, all, carve=2
color magenta, neg
color marine, pos
util.cbay
show cartoon
color deepsalmon, resi 1-18
color lightblue, resi 19-161
color wheat, resi 162-193
create all4anstdist, br. all  w. 4 of resi 401
show sticks, all4anstdist
color orange, resi 401
color blue, elem n
color red, elem o
set stick_radius=0.15
set stick_radius, 0.5,resi 401
set mesh_width=0.25
set mesh_quality=1
set_view (\
     0.246628925,   -0.152454734,   -0.957042992,\
     0.716652513,    0.693470299,    0.074210867,\
     0.652366519,   -0.704170167,    0.280287117,\
     0.000000000,    0.000000000, -163.377670288,\
   -21.975559235,    8.348320961,    0.893184662,\
   122.945655823,  203.809768677,  -20.000000000 )
### cut above here and paste into script ###
bg_color white
ray 2000,1000
png globalview1.png
turn x,180
ray 2000,1000
png globalview2.png
###domN
set_view (\
    -0.295794129,   -0.839102983,    0.456474930,\
     0.185329974,    0.418365777,    0.889155090,\
    -0.937082410,    0.347619832,    0.031767897,\
    -0.000705507,   -0.000845447,  -72.201705933,\
   -23.025413513,   18.996891022,    6.287287712,\
    48.865760803,   95.547683716,  -20.000000000 )
### cut above here and paste into script ###
###dom C
ray 2000,1000
png viewNterm.png
set_view (\
     0.151876986,   -0.973265886,    0.172172755,\
    -0.766153991,   -0.005883702,    0.642604709,\
    -0.624434531,   -0.229508713,   -0.746579826,\
     0.000152677,   -0.000805255,  -44.669643402,\
   -17.677366257,    8.265438080,   -6.837474823,\
    21.313266754,   67.995155334,   20.000000000 )
### cut above here and paste into script ###
ray 2000,1000
png viewCterm.png
###car
### cut below here and paste into script ###
set_view (\
    -0.308944672,    0.662696600,    0.682170630,\
     0.169661820,   -0.667353868,    0.725144744,\
     0.935812354,    0.339761615,    0.093743809,\
     0.000000000,    0.000000000,  -77.263153076,\
   -19.771917343,   14.284086227,    3.797000885,\
    53.922145844,  100.604103088,  -20.000000000 )
ray 2000,1000
png viewCar.png
### cut above here and paste into script ###