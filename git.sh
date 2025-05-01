#!/bin/bash

# commit args
COMMIT_MSG="$1"

DIR_A="vitis/src"
DIR_B="workspace/test_project/src"
if [ ! -d "$DIR_B" ]; then
    echo "Directory $DIR_B does not exist. Exiting."
    exit 1
fi

if ! diff -qr "$DIR_A" "$DIR_B" > /dev/null; then
    echo "Differences found between $DIR_A and $DIR_B. Copying changes from $DIR_B to $DIR_A..."
    
    rsync -av --exclude='.git/' "$DIR_B/" "$DIR_A/"
    
    echo "Files copied from $DIR_B to $DIR_A."
    git add "$DIR_A"
    git commit -m "$COMMIT_MSG"
else
    echo "No differences found between $DIR_A and $DIR_B."
fi