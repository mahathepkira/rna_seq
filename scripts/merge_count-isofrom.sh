#!/bin/bash

# Set the folder path containing the data files
folder_path="/data/home/results/RSEM_results"

# Create a temporary directory for intermediate files
temp_count_dir=$(mktemp -d)
temp_FPRK_dir=$(mktemp -d)
temp_TPM_dir=$(mktemp -d)

# Initialize an empty file for merged results
merged_file_count="${folder_path}/RxHN_isoforms_count_results.tsv" # you can change result name this line
touch "$merged_file_count"
merged_file_FPRK="${folder_path}/RxHN_isoforms_FPRK_results.tsv"  # you can change result name this line
touch "$merged_file_FPRK"
merged_file_TPM="${folder_path}/RxHN_isoforms_TPM_results.tsv"    # you can change result name this line
touch "$merged_file_TPM"

# Get all files that end with '.isoforms.results'
files=$(find "$folder_path" -name '*.isoforms.results'| sort )

# Initialize a variable to track the first file
first_file_count=1
first_file_FPRK=1
first_file_TPM=1

# Loop over each file
for file in $files; do
    # Extract the base name without the extension
    base_name=$(basename "$file" .isoforms.results)

    # Use awk to extract necessary columns, rename 'expected_count', and write to a temp file
    awk -v fname="$base_name" 'BEGIN{FS=OFS="\t"} NR==1 {if (FNR == 1) print "transcript_id", fname; next} {print $1, $5}' "$file" > "${temp_count_dir}/${base_name}.tsv"
    awk -v fname="$base_name" 'BEGIN{FS=OFS="\t"} NR==1 {if (FNR == 1) print "transcript_id", fname; next} {print $1, $7}' "$file" > "${temp_FPRK_dir}/${base_name}.tsv"
    awk -v fname="$base_name" 'BEGIN{FS=OFS="\t"} NR==1 {if (FNR == 1) print "transcript_id", fname; next} {print $1, $6}' "$file" > "${temp_TPM_dir}/${base_name}.tsv"

    #count
    if [ "$first_file_count" -eq 1 ] ; then
        # For the first file, simply copy it to the merged file
        cp "${temp_count_dir}/${base_name}.tsv" "$merged_file_count"
        first_file_count=0
    else
        # For subsequent files, join with the existing merged file
        # Note: join requires sorted files
        join -a 1 -a 2 -e '0' -o auto -t $'\t' "$merged_file_count" "${temp_count_dir}/${base_name}.tsv" > "${temp_count_dir}/temp_merged_count.tsv"
        mv "${temp_count_dir}/temp_merged_count.tsv" "$merged_file_count"
    fi
    
    #FPRK
    if [ "$first_file_FPRK" -eq 1 ] ; then
        # For the first file, simply copy it to the merged file
        cp "${temp_FPRK_dir}/${base_name}.tsv" "$merged_file_FPRK"
        first_file_FPRK=0
    else
        # For subsequent files, join with the existing merged file
        # Note: join requires sorted files
        join -a 1 -a 2 -e '0' -o auto -t $'\t' "$merged_file_FPRK" "${temp_FPRK_dir}/${base_name}.tsv" > "${temp_FPRK_dir}/temp_merged_FPRK.tsv"
        mv "${temp_FPRK_dir}/temp_merged_FPRK.tsv" "$merged_file_FPRK"
    fi
    
    #TPM
    if [ "$first_file_TPM" -eq 1 ] ; then
        # For the first file, simply copy it to the merged file
        cp "${temp_TPM_dir}/${base_name}.tsv" "$merged_file_TPM"
        first_file_TPM=0
    else
        # For subsequent files, join with the existing merged file
        # Note: join requires sorted files
        join -a 1 -a 2 -e '0' -o auto -t $'\t' "$merged_file_TPM" "${temp_TPM_dir}/${base_name}.tsv" > "${temp_TPM_dir}/temp_merged_TPM.tsv"
        mv "${temp_TPM_dir}/temp_merged_TPM.tsv" "$merged_file_TPM"
    fi
done

# Remove temporary directory
rm -rf "$temp_count_dir"
rm -rf "$temp_FPRK_dir"
rm -rf "$temp_TPM_dir"

#cp $merged_file /data/home/lattapol/casava_project/Nextflow/single/HN_rsem
echo "Merged data written to $merged_file_count"
echo "Merged data written to $merged_file_FPRK"
echo "Merged data written to $merged_file_TPM"
