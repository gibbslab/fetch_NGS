#!/bin/bash

# ---------------------------------------------------------------------
# version 2.0
# This script calls the nf-core/fetchngs pipeline as
# implemented at GiBBS.
# Institute for Genetics - National University of Colombia

# Coding was implemented according to the BASH best practices here:
# https://bertvv.github.io/cheat-sheets/Bash.html
# ---------------------------------------------------------------------




# ---------------------------------------------------------------------
# FUNCTIONS
# ---------------------------------------------------------------------

# Checks if a file or directory exists.
# Receives 2 arguments. $1:Path to target and $2:type: dir(d) or file(f))

function exists (){	

local target="${1}"
local type="${2}"

if [[ "${type}" == "f" ]];then

	if [ -f "${target}" ];then
		return 1
	else
		return 0
	fi

elif [[ "${type}" == "d" ]];then

	if [ -d "${target}" ];then
		return 1
	else
		return 0
	fi

else
	echo "Missing or wrong parameter in calling function exists()"
	exit 1
fi

}


# ---------------------------------------------------------------------
# The following parameters should be provided:
#    Mandatory
# 1) Identifiers provided in a txt file, one per line. These can be from SRA, ENA, DDBJ, GEO or Synapse repositories
# 2) Specifies the type of identifier provided {'sra', 'synapse'}
# 3) Provide a name. A samplesheet for direct use with the nf-core/rna-seq pipeline will be created {'rnaseq'}
# 4) The output directory where the results will be saved
#    Optional
# 5) CPUs
# 6) Max memory to be used
# 7) (-x): If this run is a resume or a new job

# ---------------------------------------------------------------------


while getopts i:t:n:o:p:m:x: flag
do
    case "${flag}" in
        i) ID=${OPTARG};;
        t) type=${OPTARG};;
        n) name=${OPTARG};;
        o) output=${OPTARG};;
        p) cpu=${OPTARG};;
        m) memory=${OPTARG};;
        x) resume=${OPTARG};;
       \?) echo "Invalid option: $OPTARG" 1>&2;;
        :) echo "Invalid option: $OPTARG requires an argument" 1>&2;;
    esac
done

# if none parameter is passed:
if [ $# -eq 0 ]; then

    echo ""
    echo ""
    echo "   ---------------------------------------------------------"
    echo ""
    echo "         GiBBS Retrieving and storing sequencing files        "
    echo "           Bioinformatics and Systems Biology Group           "
    echo "   Institute for Genetics - National University of Colombia   "
    echo "                  https://gibbslab.github.io/                 "
    echo ""
    echo "   ---------------------------------------------------------"
    echo ""
    echo " **Empty parameters! Unable to run**. Please provide the following parameters:"
    echo "
            Mandatory
 	-i: Identifiers provided in a txt file, one per line. These can be from SRA, ENA, DDBJ, GEO or Synapse repositories
    	-t: Specifies the type of identifier provided {'sra', 'synapse'}
	-n: Provide a name. A samplesheet for direct use with the nf-core/rna-seq pipeline will be created (CSV) {'rnaseq'}
	-o: The output directory where the results will be saved
	    Optional
 	-p: CPUs
 	-m: Max memory to be used (ej. -m 100.GB) Please note the syntaxis.
	-x: resume a previous Job. Options: y/n
	    
	 "

    exit 1
fi

# ---------------------------------------------------------------------

#                   COMMAND LINE VALIDATION
# This section evaluates the input and performs a series of
# steps based on whether a given parameter is set or not.

# ---------------------------------------------------------------------


# Mandatory: Identifiers
if [ -z "${ID}" ];then
	printf "Missing Identifiers File. Please provide it and run again.\n"
	exit 1
else
	#Target is a file (f)
	t="f"
	exists ${ID} ${t}	
	#Check return value, can be 1 or 0.
	if [ $? -eq 0 ];then
		printf "${ID} not found. Quitting.\n"
		exit 1	
	fi
	
	unset ${t}
fi


# Mandatory: Type of identifier
if [ -z "${type}" ];then
	printf "Missing Identifier Type. Please provide sra or synapse and run again.\n"
	exit 1
fi


# Mandatory: Samplesheet name
if [ -z "${name}" ];then
	printf "Missing samplesheet name. Please provide it and run again.\n"
	exit 1
fi


# Mandatory: Name of output directory
if [ -z "${output}" ];then
        printf "Output not provided.\n"
        output="SRA"
else
    printf "Output set to: ${output}.\n"

fi


# Optional: CPU
if [ -z "${cpu}" ];then
	cpu=$(cat /proc/cpuinfo | grep -c 'processor')
	printf "CPUs to use not provided. Using all $cpu cores available.\n"
fi


# Optional: Memory
if [ -z "${memory}" ];then
	memory=$(vmstat -s -S M | grep 'total memory' | awk '{ print $1 / (1024) }'  | awk '{ print int($1+0.5) }')
	printf "Max memory not provided. Using all $memory GB of memory.\n"
fi


# Optional: Resume previous job
if [[ "$resume" == "y" ]];then
	printf "Resuming previous Job\n"
	again="-resume"
elif [[ "$resume" == "n" ]];then
	printf "Starting a new Job\n"
	again=" "
else
	printf "Missing option y/n for resuming process (-x option). Quitting.\n"
	exit 1
fi


# ---------------------------------------------------------------------
#
# Let's prepare the command line
#
# ---------------------------------------------------------------------
command="nextflow run nf-core/fetchngs $again \
      --input $ID \
      --outdir $output \
      --input_type $type \
      --nf_core_pipeline $name  \
      --max_cpus $cpu \
      --max_memory $memory.GB \
      --force_sratools_download \
      -profile docker "



#Create a file with the complete command line

timestamp=$(date "+%Y%m%d-%H%M%S")
printf "${command}" > ${timestamp}.COMMAND 

#-------------------------------------------
# RUN ME!!!!# RUN ME!!!!!!
#-------------------------------------------
$command

#-------------------------------------------
# POST RUN SET UP
#-------------------------------------------

# Verify if raw data was downloaded
cd ${output}

data="fastq"
if [ -z "${data}" ];then
	printf "Sorry no data downloaded. Please check and run again.\n"
	exit 1
else
	
	#Target is a Dir (d)
	t="d"
	exists ${data} ${t}	
	#Check return value, can be 1 or 0.
	if [ $? -eq 0 ];then
		printf "${data} not found. Quitting.\n"
		exit 1	
	fi
	
	unset ${t}
fi

# Know if the fastq number corresponds to the number of IDs provided
cd ./fastq

ls -1 | wc -l
