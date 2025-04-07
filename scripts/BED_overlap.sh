#!/bin/bash -e

#SBATCH -p bio-ds                                   # Specifying the bio-ds partition
#SBATCH --qos=bio-ds                                # User group gives you access to bio-ds partition
#SBATCH --time=0-1                                  # Time limit of 1 hour
#SBATCH --mem=4G                                    # Memory limit of 4Gb
#SBATCH --job-name=BED_overlap                      # Job name
#SBATCH -o bedOverlap.STDOUT                        # STDOUT
#SBATCH -e bedOverlap.STDERR                        # STDERR
# #SBATCH --mail-type=ALL                           # Send email on job start, end, and abort
# #SBATCH --mail-user=myemail@uea.ac.uk             # Email address

# Load bedtools
echo "Loading bedtools module"
module load bedtools
echo "Loading bedtools module complete"


# Make variables for the BED files
# Note that if these files are removed from the HPC, you will need to replace these paths with new paths to the .bed files.
dIndels="/gpfs/data/BIO-DSB/Session2/Part1/DPure_indels_mask.bed"
lIndels="/gpfs/data/BIO-DSB/Session2/Part1/LPure_indels_mask.bed"
echo "BED files loaded"

# Define the output directory
bedfiles_output="bedfiles_output"
mkdir -p $bedfiles_output # Create output directory if it does not exist
echo "Output directory created"

# Your supervisor asks:
# "What is the overlap in indels between your D and L D. melanogaster populations?"

# This can be attempted using some basic commandline tools, which look to identify lines that match between the two bed files.

echo "Finding overlaps using basic commandline tools" 
# This first line simply looks for matching lines between the two files, and prints them to a new file
grep -Ff $dIndels $lIndels > $bedfiles_output/full_matching_lines.bed
# The next looks for matching lines between the two files, but omits feature name column
awk 'NR==FNR {key[$1,$2,$3]; next} ($1,$2,$3) in key' $dIndels $lIndels > $bedfiles_output/matching_chromosome_start_end.bed
# The next looks for matching lines between the two files, but omits feature name column
awk 'NR==FNR {key[$1,$2]; next} ($1,$2) in key' $dIndels $lIndels > $bedfiles_output/matching_chromosome_start.bed
# The next looks for matching lines between the two files, but only includes the chromosome column
awk 'NR==FNR {key[$1]; next} ($1) in key' $dIndels $lIndels > $bedfiles_output/matching_chromosome.bed


# Try to think about documenting what you have done, and how to assess
# whether you have been successful in identifying the overlap between
# DPure_indels_mask.bed and LPure_indels_mask.bed.

# The lines above document the process and the output.
# To sanity check the results manually, you could copy random lines from the output bedfiles and search for them in the original files.
# If the lines appear in both LPure_indels_mask.bed and DPure_indels_mask.bed, then the method has been successful.


#  Use BEDtools to find the overlap:
#    - Use the BEDtools documentation to find which command is best suite for this task.
#    - Use the command to perform the task.

echo "Finding overlaps using bedtools"
# bedtools -h # Check the help page for bedtools
# The command we are looking for is intersect, which finds the overlap between two bed files.
# bedtools intersect -h # Check the help page for the intersect command to find how we can refine our search

# We can then perform different types of intersection using the intersect command.

# The default is to find the overlap between the two files.
bedtools intersect -a $dIndels -b $lIndels > $bedfiles_output/bedtools_default.bed

# We can add additional arguments to alter the search.
# The -f flag specifies the minimum overlap required to be considered a match.
# The -r flag specifies that the overlap should be calculated as a ratio of the length of the feature in file A.
bedtools intersect -a $dIndels -b $lIndels -f 0.5 -r > $bedfiles_output/bedtools_r_f05.bed

# The -s flag specifies that the strand should be taken into account when calculating the overlap.
bedtools intersect -a $dIndels -b $lIndels -f 0.5 -r -s > $bedfiles_output/bedtools_same_stranded.bed
# Note that as our bedfiles do not include a strand orientation column, this file is expected to be empty.
echo "Overlaps found using bedtools in three different ways"

#  Document your process and assess your results:
#    - Has it worked? How do you know?
#    - Did it give the same or different output compared to your Unix-based method from the groupwork?
#    - How will you assess this?

# The different outputs to detect overlaps are saved in the bedfiles_output directory.
# The results can be assessed by comparing the number of lines in each output file.

echo "Counting the number of overlaps detected for all methods"
# Create a file to show the number of overlaps detected
output_file="$bedfiles_output/overlap_counts.txt"

# Create the output file and add a header
echo -e "File_Name\tOverlap_Count" > $output_file

# Loop through all .bed files in that we created in bedfiles_output
for bed_file in bedfiles_output/*.bed; do
    # Count the number of lines which represents the number of overlaps detected
    line_count=$(wc -l < "$bed_file")
    # Append the line count and file name to the output file so we can compare the results
    echo -e "$bed_file\t$line_count" >> $output_file
done

echo "All processes completed"

# The process was successful in that bedtools generated .bed files that included the overlaps between the two files.
# Once again sanity checking the outputs with the original files is a good way to check the results.
# There were different outputs between bedtools and the unix commands.
# This can be seen in the overlap_counts.txt file, which shows the number of overlaps detected by each method.

# As there are many ways of detecting overlaps, there must be a precise question posed in order to select a method that is most appropriate.
# The instructions given were to vague to determine this. 
# However, bedtools has been developed for the specific purpose of detecting overlaps.
# Therrefore it is likely to be the a more accurate method, than using simple commandline tools.
# The exact arguments to use are dependent on the exact question posed.
