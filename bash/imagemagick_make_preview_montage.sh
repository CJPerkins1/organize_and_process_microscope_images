#!/usr/bin/env bash

# To be run from directory containing directories for each well after 
# leica_organize_image_seq_folder.sh script is run. 

# Getting the image sequence basename
sequence_name=${PWD##*/}

mkdir ${sequence_name}_montage

# Making the montages (82 frames in 2 hours, using frames 000, 025, 050, 075)
for i in A1 A2 A3 A4 A5 A6 B1 B2 B3 B4 B5 B6 C1 C2 C3 C4 C5 C6 D1 D2 D3 D4 D5 D6; do
	montage -border 2 -geometry +0+0 -tile 2x2 \
		well_${i}/${sequence_name}_${i}_t000.tif \
		well_${i}/${sequence_name}_${i}_t025.tif \
		well_${i}/${sequence_name}_${i}_t050.tif \
		well_${i}/${sequence_name}_${i}_t074.tif \
		${sequence_name}_montage/${sequence_name}_${i}_montage.jpg

	mogrify -font Arial-Bold -fill white -pointsize 100 \
		-draw "text 50,125 '${sequence_name}_${i}'" \
		${sequence_name}_montage/${sequence_name}_${i}_montage.jpg		
	
	mogrify -font Arial-Bold -fill white -pointsize 100 -gravity West \
		-draw "text 50,-75 't000'" \
		${sequence_name}_montage/${sequence_name}_${i}_montage.jpg		

	mogrify -font Arial-Bold -fill white -pointsize 100 -gravity Center \
		-draw "text 152,-75 't025'" \
		${sequence_name}_montage/${sequence_name}_${i}_montage.jpg		

	mogrify -font Arial-Bold -fill white -pointsize 100 -gravity SouthWest \
		-draw "text 50,20 't050'" \
		${sequence_name}_montage/${sequence_name}_${i}_montage.jpg		

	mogrify -font Arial-Bold -fill white -pointsize 100 -gravity South \
		-draw "text 152,20 't075'" \
		${sequence_name}_montage/${sequence_name}_${i}_montage.jpg		
done
