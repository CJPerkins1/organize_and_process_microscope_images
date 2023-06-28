#!/usr/bin/env bash

# Check to see if there are any videos to process
echo "Searching for image sequences"

image_sequence_count=$(find /xdisk/rpalaniv/cjperkins1/chronic_hs/images/source_tifs/ -maxdepth 1 -name '*run*' | wc -l)

# If no image sequences, exits the script
if [ ${image_sequence_count} = 0 ]
then
	echo "No image sequences, exiting"
	exit 1
fi

echo "Found ${image_sequence_count} image sequences"

# Makes a directory for the logs
echo "Making log directory"
folder_name=$(date -I)

mkdir /groups/rpalaniv/backed_up/calvin/image_processing/logs/${folder_name}
cd /groups/rpalaniv/backed_up/calvin/image_processing/logs/${folder_name}

# Runs Slurm script with the right array number
echo "Running Slurm script with array of ${image_sequence_count}"

# I think I can just pass in the array number as an sbatch option, with the varible. Apparently the commend line options take precidence over the header options. 

sbatch --array=1-${image_sequence_count} /home/u28/cjperkins1/git/organize_and_process_microscope_images/slurm/process_image_sequences_camera_2.slurm

