#!/bin/bash
# J Baxter 2020
# Will replace / update the location directory for scripts in the maps directory
echo "Editing loc variable... "

replace () {
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  sed -i '0,/loc="/{/loc="/d;}' $1
  sed -i -e "2iloc=\"$DIR\"" $1
}

replace maps_for_jasper.sh
replace Extrap_maps_marius.sh
replace own_scales/make_phenix_q_weight.sh
replace map_generate.sh
replace make_dmap4_James_edited.sh
replace phenix_gen_scaled_fs.sh


echo "Done"