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

# Sourcing my .bashrc so that conda works and the path is how it should be
source /home/cedar/.bashrc
source /home/cedar/opt/conda/etc/profile.d/conda.sh

# Activating the conda environment
conda activate make_video_from_images

# Looping through the image sequence folders
for image_sequence in /srv/image_processing_folder/*trial*; do
#for image_sequence in /home/cedar/Desktop/test_dir/*trial*; do
	cd ${image_sequence}
	# Getting the image sequence basename
	sequence_name=${PWD##*/}
	printf "\nProcessing ${sequence_name}\n\n"
	
	# Fixes all the names and organizes into folder
	printf "Organizing names\n"
	bash /home/cedar/git/organize_and_process_microscope_images/bash/organize_image_sequence_folder.sh

	# Compress for upload
	printf "Compressing for upload\n"
	tar -czvf /srv/image_processing_folder/compressed/${sequence_name}.tar.gz ${image_sequence}

	# Upload to Google Drive
	printf "Uploading compressed image sequence to Google Drive\n"
	rclone copy /srv/image_processing_folder/compressed/${sequence_name}.tar.gz gdrive_ua:/microscope_images/ -v

	# Makes videos
	printf "Making videos\n"
	find "$(pwd -P)" -maxdepth 1 -name "*_*" -not -name "temp_video_frame_output" -exec \
	python /home/cedar/git/make_video_from_images/python/make_video_from_images.py \
		-i {} \
		-o {} \;

	mkdir ${sequence_name}_videos
	
	# Moves all the videos into the same directory then into the videos dir
	find -name "*.mp4" -not -path "./${sequence_name}_videos/*" -exec mv {} ./${sequence_name}_videos \;
	mv ./${sequence_name}_videos /srv/image_processing_folder/videos/

	# Uploading videos to Google Drive
	printf "Uploading videos to Google Drive\n"
	rclone copy /srv/image_processing_folder/videos/${sequence_name}_videos gdrive_ua:/microscope_videos/${sequence_name}_videos -v	

	# Moved to "processed" folder
	mv ${image_sequence} /srv/image_processing_folder/processed
	
	printf "Finished processing ${sequence_name}\n"

done

conda deactivate

printf "Finished processing all\n\n"
