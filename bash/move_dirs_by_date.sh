#!/bin/bash

src_dir="/xdisk/rpalaniv/cedar/cv/images/normalized_stabilized_jpgs/"
dest_dir="/xdisk/rpalaniv/cedar/cv/images/all_inference_images/"
date_limit=$(date -d "2022-05-23" +%s)

for dir in "$src_dir"*; do
	echo $dir
    if [[ -d $dir ]]; then
        dir_name=$(basename $dir)
		echo $dir_name
        date_str=${dir_name:0:10}  # Extract date string
		echo $date_str

        # Convert date string to Unix timestamp
        date_dir=$(date -d "$date_str" +%s)

        # Compare dates
        if (( date_dir > date_limit )); then
			echo "Moved"
            mv "$dir" "$dest_dir"
        fi
    fi
done
