#!/bin/bash

read -p "Please enter the folder name(/data/maia/your folder name): " user_value

mkdir -p /data/maia/$user_value/conda_envs/cache/
mkdir -p /data/maia/$user_value/conda_envs/
mkdir -p /data/maia/$user_value/conda_envs/pkgs

# Define the content to be appended
content=$(cat <<EOF
module load slurm
export PIP_CACHE_DIR="/data/maia/$user_value/conda_envs/cache/"
export http_proxy="http://proxy.swmed.edu:3128"
export https_proxy="http://proxy.swmed.edu:3128"
export PATH=/bin:\$PATH
export TMPDIR=/data/tempfiles/

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="\$('/apps/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ \$? -eq 0 ]; then
    eval "\$__conda_setup"
else
    if [ -f "/apps/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/apps/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/apps/anaconda3/bin:\$PATH"
    fi
fi
unset __conda_setup
EOF
)

# Append the content to .bashrc
echo "$content" >> ~/.bashrc

# Confirm the content has been appended
echo "Content has been appended to .bashrc"


condarc_content=$(cat <<EOF
envs_dirs:
 - /data/maia/$user_value/conda_envs/
proxy_servers:
 http: http://proxy.swmed.edu:3128
 https: https://proxy.swmed.edu:3128
ssl_verify: true
pkgs_dirs:
  - /data/maia/$user_value/conda_envs/pkgs
EOF
)


echo "$condarc_content" > ~/.condarc

echo "Content has been appended to .condarc"


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
