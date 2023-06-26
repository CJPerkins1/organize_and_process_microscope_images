#!/usr/bin/env bash
#SBATCH --job-name=process_camera_2
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=5gb
#SBATCH --time=0:40:00
#SBATCH --account=rpalaniv
#SBATCH --partition=standard
#SBATCH --array=1-249%249
#SBATCH --output=%x_%A_%a.out
#SBATCH --error=%x_%A_%a.err

# Setting nullglob so that globs that match nothing don't make errors
shopt -s nullglob

# Sourcing my .bashrc so that conda works and the path is how it should be
source /home/u28/cjperkins1/.bashrc

# Activating the conda environment
conda activate process-microscope-images

cd /xdisk/rpalaniv/cjperkins1/chronic_hs/images/processed_tifs/

# Setting up the array
image_sequence=$(find . -maxdepth 1 -name '*run*' | sed -n ${SLURM_ARRAY_TASK_ID}p)

# Making sure it's not blank
if [ ${image_sequence} = "" ]
then
	echo "Image sequence is blank, exiting"
	exit 1
fi

# Looping through the image sequence folder
printf "Image sequence variable is: ${image_sequence}\n"
printf "Present working directory is: ${PWD}\n"
cd ${image_sequence}
printf "\nProcessing ${sequence_name}\n"
echo ${image_sequence}
# Getting the image sequence basename
sequence_name=${PWD##*/}
printf "\nProcessing ${sequence_name}\n"

# Stabilizing image sequences for videos
printf "Stabilizing\n"
mkdir /xdisk/rpalaniv/cjperkins1/chronic_hs/images/normalized_stabilized/${sequence_name}_normalized_stabilized
for well in well_*; do
	printf "\nProcessing ${well}\n"
	mkdir /xdisk/rpalaniv/cjperkins1/chronic_hs/images/normalized_stabilized/${sequence_name}_normalized_stabilized/${well}
	cd ${well}
	python /home/u28/cjperkins1/git/image_seq_stab/python/stab_image_seq_camera_2.py
	mv *_stab.tif /xdisk/rpalaniv/cjperkins1/chronic_hs/images/normalized_stabilized/${sequence_name}_normalized_stabilized/${well}
	cd ..
done

# Cleaning up
shopt -u nullglob
