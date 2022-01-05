#!/usr/bin/env bash
#SBATCH --job-name=process_images
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=5gb
#SBATCH --time=1:00:00
#SBATCH --account=rpalaniv
#SBATCH --partition=standard
#SBATCH --output=%x_%A_%a.out
#SBATCH --error=%x_%A_%a.err
#SBATCH --array=1-1%100

# Sourcing my .bashrc so that conda works and the path is how it should be
source /home/u16/cedar/.bashrc

# Setting nullglob so that globs that match nothing don't make errors
shopt -s nullglob

# Activating the conda environment
conda activate process-microscope-images

cd /xdisk/rpalaniv/cedar/image_processing/source_tifs/

# Setting up the array
image_sequence=$(find . -maxdepth 1 -name '*run*' | sed -n ${SLURM_ARRAY_TASK_ID}p)

# Check to see if you have to do this
# source /home/cedar/opt/conda/etc/profile.d/conda.sh
 

# Looping through the image sequence folder
printf "Image sequence variable is: ${image_sequence}\n"
printf "Present working directory is: ${PWD}\n"
cd ${image_sequence}
printf "\nProcessing ${sequence_name}\n"
echo ${image_sequence}
# Getting the image sequence basename
sequence_name=${PWD##*/}
printf "\nProcessing ${sequence_name}\n"


# Fixes all the names and organizes into folder
printf "Organizing names\n"
bash /home/u16/cedar/git/organize_and_process_microscope_images/bash/leica_organize_image_seq_folder.sh


# Compress organized images for Google Drive upload
printf "Compressing images for upload\n"
tar -czvf /xdisk/rpalaniv/cedar/image_processing/compressed_tifs/${sequence_name}.tar.gz .


# Make montages
printf "Making montages\n"
# Setting thread limit
MAGICK_THREAD_LIMIT=8
bash /home/u16/cedar/git/organize_and_process_microscope_images/bash/imagemagick_make_preview_montage.sh
mv ${sequence_name}_montage /xdisk/rpalaniv/cedar/image_processing/montages


# Stabilizing image sequences for videos
printf "Stabilizing\n"
mkdir ${sequence_name}_stabilized_images
for well in well_*; do
	printf "\nProcessing ${well}\n"
	mkdir ${sequence_name}_stabilized_images/${well}
	cd ${well}
	python /home/u16/cedar/git/image_seq_stab/python/stab_image_seq.py
	mv *_stab.tif ../${sequence_name}_stabilized_images/${well}
	cd ..
done


# Make videos
printf "Making videos\n"
cd ${sequence_name}_stabilized_images/
find "$(pwd -P)" -maxdepth 1 -name "well_*" -not -name "temp_video_frame_output" -exec \
python /home/u16/cedar/git/make_video_from_images/python/leica_make_video_from_images.py \
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

mv ${sequence_name}_videos /xdisk/rpalaniv/cedar/image_processing/videos

#### For now not using rclone, have a Timer set up with Globus

# Moved to "processed" folder
mv ${sequence_name} /xdisk/rpalaniv/cedar/image_processing/processed_tifs 
#
#printf "Finished processing ${sequence_name}\n"


# Cleaning up
conda deactivate
shopt -u nullglob
# 
# if test -n /srv/image_processing_folder/*trial*
# then
#         printf "No image sequences to process\n\n"
# else
#         printf "Finished processing all\n\n"
# fi
