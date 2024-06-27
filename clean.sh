#!/bin/bash


folders_to_delete=(~/.conda/pkgs ~/.cache)


for folder in "${folders_to_delete[@]}"; do
    if [ -d "$folder" ]; then
        rm -rf "$folder"
        echo "Deleted $folder and its contents."
    else
        echo "$folder does not exist."
    fi
done


echo "Deletion of specified folders is complete."



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
