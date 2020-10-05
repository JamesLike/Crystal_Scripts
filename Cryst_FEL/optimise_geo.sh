#!/bin/bash
#J Baxter 2020

process_script="/dls/x05-1/data/2020/mx15722-24/processing/james/detector_ref/2/geoms/og/jvt_run_0004_EDIT.sh"
geom_output="/dls/x05-1/data/2020/mx15722-24/processing/james/detector_ref/2/geoms/"
geom_OG = "/dls/x05-1/data/2020/mx15722-24/processing/james/detector_ref/2/geoms/OG/rayonix-mx225hs-4x_0004_EDITED.geom"
if [ ! -f $geom_OG ]; then echo "$geom_OG not found!" && exit 1 ; fi
if [ ! -d $geom_output ]; then echo "$geom_output not found!" && exit 1 ; fi
if [ ! -d $process_script ]; then echo "$process_script not found!" && exit 1 ; fi

#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

clength=135.0
while [ $clength -le 145 ]
do
	echo $clength
	 echo "clen = $clength"> "${geom_output}rayonix-mx225hs-4x_0004_EDITED_${clength}.geom"
	 cat $geom_og >> "${geom_output}rayonix-mx225hs-4x_0004_EDITED_${clength}.geom"
   #$process_script "00004_$clength" "/dls/x05-1/data/2020/mx15722-24/processing/data/0000004" "${geom_output}rayonix-mx225hs-4x_0004_EDITED_${clength}.geom"

   echo "Submitting job.."
   qsub -l redhat_release=rhel7 -l m_mem_free=3G -cwd -pe smp 20 -q medium.q $process_script "00004_$clength" "/dls/x05-1/data/2020/mx15722-24/processing/data/0000004" "${geom_output}rayonix-mx225hs-4x_0004_EDITED_${clength}.geom"
   clength=$((clength=clength+1))
done
