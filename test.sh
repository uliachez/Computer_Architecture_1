#!/bin/bash

check(){
    # Checking whether the input is a number
    while true; do
        echo "Enter a number of MB:"
        read NUMBER1

        if [[ "$NUMBER1" =~ ^[0-9]+$ ]]; then
            break  # Exit the loop if the number is valid
        else
            echo "Error: try again."
        fi
    done
}
generation() {
    sh_variable=$NUMBER1
    dd if=/dev/zero of=myfolder.img bs=1M count=$sh_variable
    export size=$sh_variable

    # Formatting a file image to a file system ext4
    mkfs.ext4 myfolder.img

    # Creating a directory for mounting
    mkdir -p ~/myfolder

    # Mounting the image to the created directory
    mount -o loop myfolder.img ~/myfolder

    TARGET_DIR="/home/nastya/myfolder"
    chmod a+w "$TARGET_DIR"
}

files(){
    MAX_FILE_SIZE=$1
    NUM_FILES=$2
    cd "$TARGET_DIR" || exit

    # A loop for creating files
    for i in $(seq 1 $NUM_FILES); do
        dd if=/dev/zero of=file_$i.bin bs=1M count=$MAX_FILE_SIZE
    done

    cd ~
}

delete(){
    if [ -d ~/backup ]; then
    rm -r ~/backup        # Deleting the directory
    fi

    if [ -d ~/myfolder ]; then
    rm -r ~/myfolder         # Deleting the directory
    fi
}

f() {
    if [ -f /home/nastya/hello.sh ]; then
        chmod +x /home/nastya/hello.sh
        k=$1
        if [ $# -eq 1 ]; then
            /home/nastya/hello.sh "$TARGET_DIR" $k
        else
            /home/nastya/hello.sh "$TARGET_DIR"
        fi
else
  echo "File /home/nastya/hello.sh is not found."
fi
}
#Test 1 without second argument
echo "Test 1:"
check
generation
files 70 10
f
delete

#Test 2 with second argument which less than nessesary number of files
echo "Test 2:"
check
generation
files 80 10
f 1
delete

#Test 3 with second argument which more than number of existed files
echo "Test 3:"
check
generation
files 70 12
f 40
delete

#Test 4 without number of files for archivation
echo "Test 4:"
check
generation
files 70 12
f 0
delete

echo "Test 5:"
check
generation
files 70 12
f
delete


