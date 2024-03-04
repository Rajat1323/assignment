#!/bin/bash

# Function to sanitize URLs and titles
sanitize() {
    # Remove leading and trailing whitespaces
    url=$(echo "$1" | awk '{$1=$1};1')
    title=$(echo "$2" | awk '{$1=$1};1')

    # # Remove special characters from titles
    # title=$(echo "$title" | tr -cd '[:alnum:][:space:]-,')
    
    echo "$url,$title"
}

# Function to categorize URLs and consolidate titles
restructure() {
    local input_file=$1
    local output_file=$2

    # Initialize associative arrays to store categories and titles
    declare -A categories
    declare -A titles

    # Read input file line by line
    while IFS=, read -r url title; do
        # Sanitize URL and title
        sanitized=$(sanitize "$url" "$title")
        url=$(echo "$sanitized" | cut -d',' -f1)
        title=$(echo "$sanitized" | cut -d',' -f2)

        # Extract category from URL
        category=$(echo "$url" | awk -F/ '{print $5}')

        # Add title to category
        titles[category]+="$title\n "
        
        # Add category to list
        if [[ ! " ${categories[@]} " =~ " ${category} " ]]; then
            categories+=([$category]=1)
        fi
    done < "$input_file"

    # Write output CSV
    echo -n "URL," > "$output_file"
    for category in "${!categories[@]}"; do
        echo -n "$category," >> "$output_file"
    done
    echo >> "$output_file"

    for title in "${titles[@]}"; do
        echo -n "$title" | paste -sd ',' >> "$output_file"
    done
}

# Main script
input_file="input.csv"
output_file="output.csv"

restructure "$input_file" "$output_file"
