# Maps Scripts
A collection of scripts for making difference maps and doing other useful things
Scripts generally have argument explanation at the start. 

# Guide

### 1. Set paths
Most of the scripts contain a location variable for pointing at the correct scripts. This will need to be updated whenever have ported to a new system. A script called update_loc.sh will do this. Run the script in the directory where the scripts are to update. For example:
```bash
cd <script-directory>
chmod +x -R * 
./update_loc.sh
``` 
### 2. Making maps:
Main script is `maps_for_jasper.sh` it could be run in a directory with all the hkl files (except the dark) present. 
Will then tick through make all the maps, extrapolated maps and basic figures. The first few lines should be edited and set for the dataset. 
```bash
dark_obs="<full path to dark-hkl>"
dark_model="<full path to dark pdb>"
trunc_type=ethier: "_new_truncate.mtz" or "_phenix_massage.mtz" 
res_high=1.5 #Highest resolution term eg 
res_low=30   #Lowest resolution term eg 15
SYMM=19      #Symmetry group eg P212121 or 19
```
The space group will be extracted from the pdb. 
Currently all the scripts assume SG19. Edits in the following scripts should be made if changing space group:
```buildoutcfg
./progs/neg.sh
(almost all others)
```


