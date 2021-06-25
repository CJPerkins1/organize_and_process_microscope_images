#!/usr/bin/env bash

# Getting the image sequence basename
sequence_name=${PWD##*/}

mkdir scratch

mv *thumb* scratch
mv *.nd scratch

# For _TRIAL_01__
find . -name "*.TIF" | awk -F "_" -v mvcmd='mv "%s" "%s"\n' '{old=$0; gsub(/s/,"",$5); gsub(/t/,"",$6); new=sprintf("%s_%s_%s_%ss%02d_t%02d.tif", $1,$2,$3,$4,$5,$6); printf mvcmd,old,new;}' | sh

# For _trial01_
#find . -name "*.TIF" | awk -F "_" -v mvcmd='mv "%s" "%s"\n' '{old=$0; gsub(/s/,"",$3); gsub(/t/,"",$4); new=sprintf("%s_%s_s%02d_t%02d.tif", $1,$2,$3,$4); printf mvcmd,old,new;}' | sh

# Making folders for each well and moving the images into the folders
for i in {01..24..1}; do
	mkdir well_${i}	
	mv *s${i}* well_${i}
done	

# Fixing names from the snake path of the stage
mv well_01 ${sequence_name}_A1
mv well_02 ${sequence_name}_A2
mv well_03 ${sequence_name}_A3
mv well_04 ${sequence_name}_A4
mv well_05 ${sequence_name}_A5
mv well_06 ${sequence_name}_A6
mv well_07 ${sequence_name}_B6
mv well_08 ${sequence_name}_B5
mv well_09 ${sequence_name}_B4
mv well_10 ${sequence_name}_B3
mv well_11 ${sequence_name}_B2
mv well_12 ${sequence_name}_B1
mv well_13 ${sequence_name}_C1
mv well_14 ${sequence_name}_C2
mv well_15 ${sequence_name}_C3
mv well_16 ${sequence_name}_C4
mv well_17 ${sequence_name}_C5
mv well_18 ${sequence_name}_C6
mv well_19 ${sequence_name}_D6
mv well_20 ${sequence_name}_D5
mv well_21 ${sequence_name}_D4
mv well_22 ${sequence_name}_D3
mv well_23 ${sequence_name}_D2
mv well_24 ${sequence_name}_D1

# Changing the individual image names to have the correct well
for i in A1 A2 A3 A4 A5 A6 B1 B2 B3 B4 B5 B6 C1 C2 C3 C4 C5 C6 D1 D2 D3 D4 D5 D6; do
	cd ${sequence_name}_${i}
	for x in *.tif; do 
		mv $x $(echo $x | sed -E "s/s[0-9]*/$i/g")
	done
	cd ..
done

