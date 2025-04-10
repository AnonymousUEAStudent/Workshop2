#!/bin/bash

# Student ID: 100499009

# The following is a break down of the material covered in workshop 2. 
# Commentary includes descriptions of the commands used, their inteded purpose, as well as the output of the commands.
# The workshop is split into two parts, the first part covers file transfer and bash scripting.
# The second part covers the use of SLURM to submit jobs to the HPC, and requires the use of commandline operations.

# This script contains commanline operations to repeat the steps from both parts of the workshop so they can be reproduced by running this script file.
# To do so, remove the .txt file extension from this file copy it to a new folder of your choice on the UEA HPC and run the script using bash ws2.sh.
# A github repository of this exercise is included here https://github.com/AnonymousUEAStudent/Workshop2 which includes a full README.md file and instructions on how to run the script.

# Setup step to remove previous output files
rm -rf scripts/ # Remove the 'scripts' directory if it exists
rm -rf bedfiles_output/ # Remove the 'bedfiles_output' directory if it exists
rm -rf example_output.txt # Remove the 'example_output.txt' file if it exists
rm -rf simple.txt # Remove the 'example_output.txt' file if it exists
rm -rf *.STDERR # Remove any .STDERR files if they exist
rm -rf *.STDOUT # Remove any .STDOUT files if they exist


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
echo "#!/bin/bash
echo 'Hello world!'" > hello_world.sh # Create a bash script that prints "Hello world!"
# •    Copy it to the ‘scripts’ directory on the HPC using file transfer software
mv hello_world.sh scripts/ # Move the bash script to the 'scripts' directory
# •    Run the script
bash scripts/hello_world.sh # Run the bash script, which will print Hello world! to the terminal.

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
#SBATCH -o ExampleJob.STDOUT          # STDOUT
#SBATCH -e ExampleJob.STDERR          # STDERR
#SBATCH -J ExampleJobRenamed          # job name
# #SBATCH --mail-type=END,FAIL          # notifications for job done & fail
# #SBATCH --mail-user=myemail@uea.ac.uk # send-to address

echo 'This is an example of the standard output of a batch job'
echo 'This is an example of an output file from a batch job' > example_output.txt" > batch_example.sh # Create a new bash script editing the job name
# A real email should be used if you wish to run the job and get notifications, otherwise leave the email line commented out.

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
# The exact arguments to use are dependent on the exact question posed.' > scripts/BED_overlap.sh
# 2.    Test it by running it
sbatch scripts/BED_overlap.sh # Submit the script to the HPC


# That concludes the workshop 2 bash script.
# If you have not visited the repo as stated at the start of the file, the README.md is included below giving instructions on it's use:
# Available here: https://github.com/AnonymousUEAStudent/Workshop2

# # Data Science & Bioinformatics Workshop 2
# ## Bioinformatics Software and File Transfer, Scripting, bash scripts, using SLURM
# This repo includes all the required files to fully answer the questions set in this workshop, and ensuring reproducibility. It does require access to the UEA HPC to run and process the script ws2.sh as intended.
# Each file is listed here with its intended purpose:

# ## Files:
# ### Workshop2 Directory:
# - ws2.sh: A bash script that when run, will complete all the execises in workshop 2 and generate all other files described below. Instructions for how to do so are listedd later in the "Reproducing the exercise" section.
# - ws2.sh.txt: Duplicate of the above with .txt file extention, allowing for submission to blackboard. 
# - simple.txt: A generated text file containing "Simple text file"
# - example_output.txt: A text file generated by running the ExampleJob batch_example.sh on the UEA HPC.
# - *.bed: The two bed files D and L from D. melanogaster. required to perform the exercise. Included here if they are removed from the HPC in future, and the ws2.sh needs to updated to use new paths for these files.
# ### scripts Directory:
# - hello_world.sh: A simple bash script that outputs "Hello world!" when run.
# - threeCommands.sh: Simple bash script that lists the current directory contents and creates then deletes a txt file.
# - batch_example.sh: A batch job intended to be run on the UEA HPC. Will generate the example_output.txt file when run.
# - BED_overlap.sh: A more complicated batch job intended to be run on the UEA HPC. It will use various methods to determine overlaps in two .bed files located on the HPC (If these files are removed on the HPC new paths will need to be replaced to point to a new location of the  bedfiles in ws2.sh).
# ### bedfiles_output Directory:
# - bedtools_default.bed: Default output running bedtools intersect on the two .bed files
# - bedtools_r_f05.bed: Output running bedtools intersect with -r and -f 0.5 flags on the two .bed files
# - bedtools_same_stranded.bed: Output running bedtools intersect with -r -f 0.5 and -s flags on the two .bed files
# - full_matching_lines.bed: Output from using grep -Ff to find match lines between the two .bed files
# - matching_*.bed: The files generated with only the listed matching columns using awk.
# - overlap_counts: A text file containing the file names and the number of lines generate in each (The number of overlaps)

# ## Reproducing the exercise:
# Login to the UEA HPC and navigate to a location you wish to clone the repository.
# Clone the repo in a location on the UEA HPC and use cd to navigate into the repo folder created:
# ```
# git clone https://github.com/AnonymousUEAStudent/Workshop2.git
# cd Workshop2
# ```
# Alternatively, if just the ws2.sh.txt file is available. Remove the .txt extension and copy the file to a folder of your choice on the HPC.

# Run the bash script file using: 
# ```
# bash ws2.sh
# ```
# The script includes a few setup lines to ensure the script is reproducible when running multiple times.
# This includes the deletion of files and folders generated during the script.
# Running the script will produce the output described in the ws2.sh(.txt) file(s).

# A summary of what the script achieves is listed below:
# First the Workshop2 directory is reset to remove all previously generated output.
# Creates a new subdirectory 'scripts' within the current directory.
# Then generates two bash scripts hello_world.sh and threeCommands.sh.
# It runs the three commands script.
# It also generates two batch scripts for use in the HPC.
# All scripts are saved in the scripts directory.
# It then runs the two batch scripts on the HPC and generates the output files described in the files section.