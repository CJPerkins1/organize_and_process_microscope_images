#!/usr/bin/env bash

# This script will process all image sequences in /srv/image_processing_folder
# It is meant to be run nightly with cron, but can also be triggered manually 
# with the command "process", providing the following line is present in the 
# user's ~/.bashrc file:
#
# alias process='bash /srv/scripts/process_image_sequences.sh'
#
# Things that happen when this script is run (all this happens in a for loop
# for each image sequence folder in the directory):
#
# 0) check if connected to internet (if the laptop is having problems)
#    note: can we get an ethernet connection?
# 1) raw image sequence folders are compressed with tar
# 2) uncompressed image sequences are organized into subfolders according to 
#    well using the script "organize_image_sequences.sh" (maybe this should 
#    happen before compression, and make the file names for each well unique)
# 3) image sequences are turned into videos using the script 
#    "make_video_from_images.py" (likely after loading conda environment,
#    maybe do this at the very start)
# 4) videos are organized into folders using some bash script (see slurm)
# 5) videos and compressed image sequences are uploaded to Google Drive using 
#    rclone.

# # Sourcing my .bashrc so that conda works and the path is how it should be
# source /home/cedar/.bashrc
# source /home/cedar/opt/conda/etc/profile.d/conda.sh
# 
# # Setting nullglob so that globs that match nothing don't make errors
# shopt -s nullglob

# # Activating the conda environment
# conda activate process-microscope-images

# Looping through the image sequence folder
# Change this to "*run*"
# Maybe add a check to make sure you aren't processing ones that have been 
# processed already (they should be in a different folder at that point)
for image_sequence in /Users/cdwarman/Desktop/Science/computer_vision/confocal_test_images/processing_dir/*plate*; do
	cd ${image_sequence}
	echo ${image_sequence}
	# Getting the image sequence basename
	sequence_name=${PWD##*/}
	printf "\nProcessing ${sequence_name}\n"
	
 
	# Fixes all the names and organizes into folder
	printf "Organizing names\n"
	bash /Users/cdwarman/git/organize_and_process_microscope_images/bash/leica_organize_image_seq_folder.sh


	# Make montages
	printf "Making montages\n"
	bash /Users/cdwarman/git/organize_and_process_microscope_images/bash/imagemagick_make_preview_montage.sh


	# Stabilizing image sequences for videos
	printf "Stabilizing\n"
	mkdir ${sequence_name}_stabilized_images
	for well in well_*; do
		printf "\nProcessing ${well}\n"
		mkdir ${sequence_name}_stabilized_images/${well}
		cd ${well}
		# Add opencv, numpy, python_video_stab to virtual environment
		python /Users/cdwarman/git/image_seq_stab/python/stab_image_seq.py
		mv *_stab.tif ../${sequence_name}_stabilized_images/${well}
		cd ..
	done


	# Make videos
	printf "Making videos\n"
	cd ${sequence_name}_stabilized_images/
	find "$(pwd -P)" -maxdepth 1 -name "well_*" -not -name "temp_video_frame_output" -exec \
	python /Users/cdwarman/git/make_video_from_images/python/leica_make_video_from_images.py \
		-i {} \
		-o {} \;

	cd ..
	mkdir ${sequence_name}_videos
	
	# Moves all the videos into the same directory then into the videos dir
	find . -name "*.mp4" -not -path "./${sequence_name}_videos/*" -exec mv {} ./${sequence_name}_videos \;
	
	# Renaming the videos here so they have the full name. 
	for i in A1 A2 A3 A4 A5 A6 B1 B2 B3 B4 B5 B6 C1 C2 C3 C4 C5 C6 D1 D2 D3 D4 D5 D6; do
    	mv ./${sequence_name}_videos/well_${i}.mp4 ./${sequence_name}_videos/${sequence_name}_${i}.mp4
	done

	# mv ./${sequence_name}_videos /srv/image_processing_folder/videos/


######## To here


	# Uploading videos to Google Drive
	printf "Uploading videos to Google Drive\n"
	#rclone copy /srv/image_processing_folder/videos/${sequence_name}_videos gdrive_ua:/microscope_videos/${sequence_name}_videos -v	


	# Compress images for upload
	printf "Compressing images for upload\n"
	# tar -czvf /srv/image_processing_folder/compressed/${sequence_name}.tar.gz ${image_sequence}


	# Upload compressed images to Google Drive
	printf "Uploading compressed image sequence to Google Drive\n"
	# rclone copy /srv/image_processing_folder/compressed/${sequence_name}.tar.gz gdrive_ua:/microscope_images/ -v

	# Uploading montages to Google Drive
	printf "Uploading montages to Google Drive\n"
	# Figure out the paths of the montage folders, make google drive folder for them
	# rclone copy /srv/image_processing_folder/compressed/${sequence_name}.tar.gz gdrive_ua:/microscope_montages/ -v



### Decide that to delete, what to keep, and where to put it (move compressed ###
### image sequences, montages, vids to external hard drive ###

	## Moved to "processed" folder
	#mv ${image_sequence} /srv/image_processing_folder/processed
	#
	#printf "Finished processing ${sequence_name}\n"

done

# # Cleaning up
# conda deactivate
# shopt -u nullglob
# 
# if test -n /srv/image_processing_folder/*trial*
# then
#         printf "No image sequences to process\n\n"
# else
#         printf "Finished processing all\n\n"
# fi
