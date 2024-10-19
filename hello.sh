#!/bin/bash

cycle (){
        while [ "$USED_PERCENTAGE" -gt "$NUMBER" ]; do # We find the N oldest files
            OLD_FILES=$(find "$TARGET_DIR" -type f -printf '%T+ %p\n' | sort | head -n 1 | awk '{print $2}')
            if [ -z "$OLD_FILES" ]; then
                echo "No more files to archive."
                break
            fi

            # Archiving the file
            tar -czf "$BACKUP_FILE" -C "$TARGET_DIR" "$(basename "$OLD_FILES")" && rm -f "$OLD_FILES"
            TOTAL_SIZE=$(du -sb "$TARGET_DIR" | awk '{print $1}') # size in bytes
            USED_PERCENTAGE=$(( ($TOTAL_SIZE * 100) / $MAX_SIZE ))
            echo "Archived: $OLD_FILES, New Usage: ${USED_PERCENTAGE}%"
        done
    }



# Checking for arguments
if [ $# -ne 1 ] && [ $# -ne 2 ]; then
echo "Usage: $0 <directory path> or/and <number of files for archiving.>"
exit 1
fi

TARGET_DIR=$1
BACKUP_DIR="backup"

# Checking if the target directory exists
if [ ! -d "$TARGET_DIR" ]; then
echo "Error: The ${TARGET_DIR} directory does not exist."
exit 1
fi

# Checking the size of the directory
TOTAL_SIZE=$(du -sb "$TARGET_DIR" | awk '{print $1}') # size in bytes
MAX_SIZE=$(($size * 1024 * 1024)) # 1 GB in bytes
USED_PERCENTAGE=$(( ($TOTAL_SIZE * 100) / $MAX_SIZE ))

echo "Using ${TARGET_DIR}: ${USED_PERCENTAGE}%"
is_true=0
M=0
if [ ! -z "$2" ]; then 
        M=$2
        is_true=1
fi


# Archiving and deletion
echo "Enter a number:"
read NUMBER

if [ $USED_PERCENTAGE -gt $NUMBER ]; then
    mkdir -p "$BACKUP_DIR" # Creating a directory if it does not exist
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.tar.gz"

    # Filtering and archiving old files
    if [ "$M" -eq 0 ] && [ "$is_true" -eq 1 ]; then 
        echo "The percentage of used space is more than ${NUMBER}%"
        cycle
    else
        if [ "$M" -eq 0 ] && [ "$is_true" -eq 0 ]; then 
            cycle
        else
            cur=0
            while [ "$cur" != "$M" ]; do
                OLD_FILES=$(find "$TARGET_DIR" -type f -printf '%T+ %p\n' | sort | head -n 1 | awk '{print $2}')
                if [ -z "$OLD_FILES" ]; then 
                    echo "No more files to archive."
                    break
                fi

                # Archiving the file
                tar -czf "$BACKUP_FILE" -C "$TARGET_DIR" "$(basename "$OLD_FILES")" && rm -f "$OLD_FILES"
                TOTAL_SIZE=$(du -sb "$TARGET_DIR" | awk '{print $1}') # size in bytes
                USED_PERCENTAGE=$(( TOTAL_SIZE * 100 / MAX_SIZE ))
                echo "Archived: $OLD_FILES, New Usage: ${USED_PERCENTAGE}%"
                
                # Increasing the counter
                cur=$((cur + 1))
            done  
            if [ $USED_PERCENTAGE -gt $NUMBER ]; then 
                echo "The percentage of used space is more than ${NUMBER}%"
                cycle
            fi
        fi
    fi
else
echo "The size of the ${TARGET_DIR} folder does not exceed ${NUMBER}%."
fi