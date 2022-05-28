#!/usr/bin/env bash

# This is an alternate version of the original script to be used with images
# from a DFC340 camera at full resolution (1600x1200).

# To be run from directory containing directories for each well after 
# leica_organize_image_seq_folder.sh script is run. 

# Getting the image sequence basename
sequence_name=${PWD##*/}

# Getting the path for the Arial Bold font (it's not on the HPC, so had
# to include in the repo).
script_path=$(dirname ${BASH_SOURCE[0]})
arial_bold_path=${script_path}/../fonts/Arial-Bold.ttf

mkdir ${sequence_name}_montage

# Making the montages (66 frames in 2 hours, using frames 000, 022, 044, 065)
for i in A1 A2 A3 A4 A5 A6 B1 B2 B3 B4 B5 B6 C1 C2 C3 C4 C5 C6 D1 D2 D3 D4 D5 D6; do
	montage -border 2 -geometry +0+0 -tile 2x2 \
		well_${i}/${sequence_name}_${i}_t000.tif \
		well_${i}/${sequence_name}_${i}_t022.tif \
		well_${i}/${sequence_name}_${i}_t044.tif \
		well_${i}/${sequence_name}_${i}_t065.tif \
		${sequence_name}_montage/${sequence_name}_${i}_montage.jpg

	mogrify -font ${arial_bold_path} -fill white -pointsize 65 \
		-draw "text 50,100 '${sequence_name}_${i}'" \
		${sequence_name}_montage/${sequence_name}_${i}_montage.jpg		
	
	mogrify -font ${arial_bold_path} -fill white -pointsize 65 -gravity West \
		-draw "text 50,-75 't000'" \
		${sequence_name}_montage/${sequence_name}_${i}_montage.jpg		

	mogrify -font ${arial_bold_path} -fill white -pointsize 65 -gravity Center \
		-draw "text 120,-75 't022'" \
		${sequence_name}_montage/${sequence_name}_${i}_montage.jpg		

	mogrify -font ${arial_bold_path} -fill white -pointsize 65 -gravity SouthWest \
		-draw "text 50,40 't044'" \
		${sequence_name}_montage/${sequence_name}_${i}_montage.jpg		

	mogrify -font ${arial_bold_path} -fill white -pointsize 65 -gravity South \
		-draw "text 120,40 't065'" \
		${sequence_name}_montage/${sequence_name}_${i}_montage.jpg		
done
