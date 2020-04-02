#!/bin/bash
#J Baxter 2020

#m=0.5
rm O_results.dat
for m in $(seq 0.5 0.25 3.5) #seq [first [incr]] last
do
N=3
while [ $N -le 15 ]
do
echo $N
xc=-2.77 #-1.74
yc=6.59
zc=-20.16
radius=$N
sigma=$m #2.5


rm -f result.dat

for d in */; do
	cd ./$d
	echo $d
	
	FILES=Fext*.map
	rm -f neg_add.dat
	for f in $FILES
	do
	
		echo $f > neg.inp
		echo mask.map >> neg.inp
		echo 4  >> neg.inp
		echo X,Y,Z >> neg.inp
		echo 1/2+X,1/2-Y,-Z >> neg.inp
		echo -X,1/2+Y,1/2-Z >> neg.inp
		echo 1/2-X,-Y,1/2+Z >> neg.inp
		echo $xc $yc $zc >> neg.inp
		echo $radius >> neg.inp
		echo $sigma >> neg.inp
		/home/jb2717/progs/marius/scripts/PROGS/NegExCCP4_v2 < neg.inp > ${f}.log
		grep 'SUM NEGATIVE DENSITY :' ${f}.log | awk '{print $5}' >> neg_add.dat

done
	echo ${N} > tmp_n
	echo ${m} > tmp_m
	sort -n -r neg_add.dat > neg_add_sort.dat
	paste COUNT.dat neg_add_sort.dat > neg.dat

	phenix.python /mnt/data4/XFEL/LR23/DED_tests/scripts/N_ext_fit_conv.py neg.dat | awk '{print $3}' > datA
	mv N_ext_Fitted_C.png ${m}_fit_${N}.png
	echo $d > datB
	paste datB datA >> ../result.dat
	paste tmp_n tmp_m datB datA >> ../O_results.dat
	rm *.log
	rm -f tmp_n tmp_m
	cd ..

done

gnuplot -e "set terminal png size 800,600; set output 'result.png'; set key off ; plot 'result.dat' using 1:(200/\$2) with linespoints, 'real_res.dat' using 1:(200/\$2) with linespoints, 'real_res.dat' using 1:(100-(200/\$2)) with linespoints"
mv result.png ${m}_result_${N}.png
N=$(( $N + 1))
done

#m=$(( $m + 1))

done
awk '{print $1, $2, $4, $3}' O_results.dat >tmp1
sed 's:/.*::' tmp1  > tmp1a
awk '{print $4,"c",$1, $2, $3}' tmp1a >tmp2
sort -tc -n tmp2 > tmp2a
sed 's/c//g' < tmp2a >tmp3 
awk '{print $1,$2,$3,$4}' tmp3 > sorted_results.dat

rm tmp1 tmp1a tmp2 tmp2a tmp3
