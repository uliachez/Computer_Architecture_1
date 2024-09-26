bash#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Using: $0 <path to folder>"
    exit 1
fi

DIR="$1"

if [ ! -d "$DIR" ]; then
    echo "Error: $DIR it is not a directory."
    exit 1
fi

USED=$(df "$DIR" | awk 'NR==2 {print $3}')
TOTAL=$(df "$DIR" | awk 'NR==2 {print $2}')

PERCENTAGE=$((USED * 100 / TOTAL))

echo "Filling in the folder $DIR: $PERCENTAGE%"
