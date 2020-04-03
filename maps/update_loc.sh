#!/bin/bash
# J Baxter 2020
# Will replace / update the location directory for scripts in the maps directory
echo "Editing loc variable... "

replace () {
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  sed -i '0,/loc="/{/loc="/d;}' $1
  sed -i -e "2iloc=\"$DIR\"" $1
}

replace ${DIR}/maps_for_jasper.sh
replace ${DIR}/Extrap_maps_marius.sh
replace ${DIR}/own_scales/make_phenix_q_weight.sh
replace ${DIR}/map_generate.sh
replace ${DIR}/make_dmap4_James_edited.sh
replace ${DIR}/phenix_gen_scaled_fs.sh
replace ${DIR}/progs/neg.sh


echo "Done"