#!/bin/bash
# J Baxter 2020
# Will replace / update the location directory for scripts in the maps directory
echo "Editing loc variable... "

replace () {
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  sed -i '0,/loc="/{/loc="/d;}' $1
  sed -i -e "2iloc=\"$DIR\"" $1
}

replace ./scratch2.sh

echo "Done"