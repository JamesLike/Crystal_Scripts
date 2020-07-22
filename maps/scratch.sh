#!/usr/bin/env bash
if mtzinfo /home/james/data/crystallography/OCP/testing/q-weighted/12/dark.mtz | head -n 5 | grep ' F '; then
    echo 'found'
elif mtzinfo /home/james/data/crystallography/OCP/testing/q-weighted/12/dark.mtz | head -n 5 | grep ' FC '; then
    echo 'notfound'
fi