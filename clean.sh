#!/bin/bash

read -p "Please enter the folder name(/data/maia/your folder name): " user_value


# Move directories larger than 0.2GB to a new location and create symbolic links
echo "Checking for directories larger than 0.2GB to move..."

for dir in ~/*; do
    if [ -d "$dir" ]; then
        dir_size=$(du -s "$dir" | awk '{print $1}')
        size_gb=$(echo "scale=2; $dir_size/1024/1024" | bc)
        if (( $(echo "$size_gb > 0.2" | bc -l) )); then
            echo "Moving $dir (size: $size_gb GB) to /data/maia/$user_value/"
            mv "$dir" "/data/maia/$user_value/"
            ln -s "/data/maia/$user_value/$(basename "$dir")" "$dir"
            echo "Moved $dir to /data/maia/$user_value/ and created a symbolic link."
        fi
    fi
done




# Check the size of the home directory and its subdirectories
echo "Checking the size of your home directory and subdirectories..."

home_dir_size=$(du -sh ~ 2>/dev/null | awk '{print $1}')
over_limit=false

# Check each subdirectory size, excluding upper level paths
for dir in ~/{.[!.],}*; do
    if [ -d "$dir" ]; then
        dir_size=$(du -sh "$dir" 2>/dev/null | awk '{print $1}')
        echo "Size of $dir: $dir_size"
    fi
done

# Function to convert size to GB
convert_to_gb() {
    size=$1
    unit=${size: -1}
    number=${size%?}
    
    case $unit in
        K) echo "scale=2; $number/1024/1024" | bc ;;
        M) echo "scale=2; $number/1024" | bc ;;
        G) echo "$number" ;;
        *) echo "0" ;;
    esac
}

total_size_gb=$(convert_to_gb $home_dir_size)

# Display total size
echo "Total size of your home directory: $home_dir_size"

# Check if total size exceeds 1GB
if (( $(echo "$total_size_gb > 2" | bc -l) )); then
    over_limit=true
fi

# Display warning if the total size exceeds 1GB
if $over_limit; then
    echo "Warning: Your home directory exceeds 2GB. Please clean up some files."
else
    echo "Your home directory is within the limit."
fi
