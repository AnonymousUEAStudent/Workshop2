#!/bin/bash

# Student ID: 100499009

# The following is a break down of the material covered in workshop 2. 
# Commentary includes descriptions of the commands used, their inteded purpose, as well as the output of the commands.
# The workshop is split into two parts, the first part covers file transfer and bash scripting, and does not require any commandline operations.
# The second part covers the use of SLURM to submit jobs to the HPC, and requires the use of commandline operations.

# I have included commanline operations to repeat the steps from both parts of the workshop so they can be reproduced by running this script file.
# To do so, remove the .txt file extension from this file and run the script using bash ws2.sh

# Part 1

# Exercise 1
# •    Download / Open VSCode
# •    Make a simple text file on your local machine
echo "Simple text file" > simple.txt # Create a simple text file

# Exercise 2
# •    Open WinSCP / FileZilla (Download if necessary) & log in 
# •    Look at the directory you created yesterday in WinSCP / FileZilla 
# •    Create a new directory using WinSCP / FileZilla called ‘scripts’
mkdir scripts # Create a new directory called 'scripts' in the current directory

# Exercise 3 
# •    Write a “Hello World” bash script in VSCode on your local machine
echo "echo 'Hello world!'" > bash.sh # Create a bash script that prints "Hello world!"
# •    Copy it to the ‘scripts’ directory on the HPC using file transfer software
mv bash.sh scripts/ # Move the bash script to the 'scripts' directory
# •    Run the script
bash scripts/bash.sh # Run the bash script

# Exercise 4
# •    Write a bash script that contains 3 of the lines of code from the Tuesday Linux session
echo "#!/bin/bash
ls -trlh
touch new_file.txt
rm -rf new_file.txt" > scripts/threeCommands.sh # Create a new bash script
# •    Copy it to the HPC using file transfer software
# •    Run the script
bash scripts/threeCommands.sh


# Part 2

# Exercise 1
# 1.    Use WinSCP / FileZilla to find the file XXX
# 2.    Copy it to your local machine using WinSCP / FileZilla 
# 3.    Look at it in VSCode 
# 4.    Edit the job name (-J) to something individual you recognise, and save

echo "#!/bin/bash -e

#SBATCH --qos=bio-ds                  # User group
#SBATCH -p bio-ds                     # Job queue (partition)
#SBATCH -N 1                          # number of nodes
#SBATCH -n 1                          # number of processes
#SBATCH -c 1                          # number of cores
#SBATCH --mem 2G                      # memory pool for all cores
#SBATCH -t 0-00:10                    # wall time (D-HH:MM)
#SBATCH -o ExampleJob.STDOUT            # STDOUT
#SBATCH -e ExampleJob.STDERR            # STDERR
#SBATCH -J ExampleJobRenamed          # job name
# #SBATCH --mail-type=END,FAIL          # notifications for job done & fail
# #SBATCH --mail-user=myemail@uea.ac.uk # send-to address

echo 'This is an example of the standard output of a batch job'

sleep 1m

echo 'This is an example of an output file from a batch job' > example_output.txt" > batch_example.sh # Create a new bash script editing the job name
# A real email should be used if you wish to run the job and get notifications

# 5.    Copy the script to the ‘scripts’ directory on the HPC (that you made earlier)
mv batch_example.sh scripts/
# 6.    Submit the script using sbatch
sbatch scripts/batch_example.sh
# 7.    Use squeue -u  your_username to look at the job in the queue
# squeue -u your_username # You will need to replace 'your_username' with your actual username if you wish to see your jobs
# 8.    Look at squeue –p bio-ds to look at everyone’s job
squeue -p bio-ds
# 9.    Look at the output of the job
# less example_output.txt
# less ExampleJob.STDOUT # Look at the output of the job
# less ExampleJob.STDERR # Look at the error output of the job

# Exercise 2
# 1.    Use the skills gained above to build the job you worked on with Karl this morning into
# a SLURM submission script

echo '#!/bin/bash -e

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
dIndels="/gpfs/home/dyj09myu/bioinformatics/BIO-DSB/Session2/Part1/DPure_indels_mask.bed"
lIndels="/gpfs/home/dyj09myu/bioinformatics/BIO-DSB/Session2/Part1/LPure_indels_mask.bed"
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
awk '\''NR==FNR {key[$1,$2,$3]; next} ($1,$2,$3) in key'\'' $dIndels $lIndels > $bedfiles_output/matching_chromosome_start_end.bed
# The next looks for matching lines between the two files, but omits feature name column
awk '\''NR==FNR {key[$1,$2]; next} ($1,$2) in key'\'' $dIndels $lIndels > $bedfiles_output/matching_chromosome_start.bed
# The next looks for matching lines between the two files, but only includes the chromosome column
awk '\''NR==FNR {key[$1]; next} ($1) in key'\'' $dIndels $lIndels > $bedfiles_output/matching_chromosome.bed


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
# The command we are looking for is 'intersect', which finds the overlap between two bed files.
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
# The exact arguments to use are dependent on the exact question posed.' > scripts/BED_overlap.sh
# 2.    Test it by running it
sbatch scripts/BED_overlap.sh # Submit the script to the HPC

# Running this script with bash ws2.sh will create a new directory called 'output' in the current directory.
# This directory will contain the output files from the BED overlap task.
