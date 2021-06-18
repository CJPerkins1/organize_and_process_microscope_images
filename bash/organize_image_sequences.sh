#!/usr/bin/env bash

mkdir scratch

mv *thumb* scratch

find . -name "*.TIF" | awk -F"_" -v mvcmd='mv "%s" "%s"\n' '{old=$0; gsub(/s/,"",$5); gsub(/t/,"",$6); new=sprintf("%s_%s_%s_%ss%02d_t%02d.TIF", $1,$2,$3,$4,$5,$6); printf mvcmd,old,new;}' | sh

for i in {01..24..1}; do
	mkdir well_${i}	
	mv *s${i}* well_${i}
done	

# Because of the snake path of the stage
mv well_01 well_A1
mv well_02 well_A2
mv well_03 well_A3
mv well_04 well_A4
mv well_05 well_A5
mv well_06 well_A6
mv well_07 well_B6
mv well_08 well_B5
mv well_09 well_B4
mv well_10 well_B3
mv well_11 well_B2
mv well_12 well_B1
mv well_13 well_C1
mv well_14 well_C2
mv well_15 well_C3
mv well_16 well_C4
mv well_17 well_C5
mv well_18 well_C6
mv well_19 well_D6
mv well_20 well_D5
mv well_21 well_D4
mv well_22 well_D3
mv well_23 well_D2
mv well_24 well_D1
