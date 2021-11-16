#!/usr/bin/env bash

# Getting the image sequence basename
sequence_name=${PWD##*/}

mkdir scratch

mv Mark_and_Find_001/*.tif .
mv Mark_and_Find_001 scratch

# Fixing leading zeros
find . -maxdepth 1 -name "*.tif" | awk -F "_" -v mvcmd='mv "%s" "%s"\n' '{old=$0; gsub(/t/,"",$3); new=sprintf("%s_t%03d.tif", $1,$3); printf mvcmd,old,new;}' | sh

# Adding the run information to the start of the names
for file in *.tif; do
	mv ${file} ${sequence_name}_${file}
done

# Making folders for each well and moving the images into the folders
for i in A1 A2 A3 A4 A5 A6 B1 B2 B3 B4 B5 B6 C1 C2 C3 C4 C5 C6 D1 D2 D3 D4 D5 D6; do
	mkdir well_${i}	
	mv *${i}*.tif well_${i}
done	

