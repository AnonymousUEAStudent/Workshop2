#!/bin/bash -e

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
echo 'This is an example of an output file from a batch job' > example_output.txt
