# organize_and_process_microscope_images
This repo contains scripts used to organize and process microscope images.

## Conda environment
To set up the Conda environment used in this repo:
```
conda create -n process-microscope-images python=3.9 ffmpeg ffmpeg-python numpy pillow opencv
```

Then from inside the environment (maybe probably this is the wrong way to do this but vidstab isn’t available from Conda):
```
pip install vidstab
```
