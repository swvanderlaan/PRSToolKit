#!/bin/bash
#SBATCH --job-name="PRS workflow"                                 #Job name
#SBATCH --output=/home/dhl_ec/aligterink/logs/batchjob_%j.log     # Standard output and error log
#SBATCH --mail-user=a.j.ligterink@umcutrecht.nl                   # Mail
#SBATCH --mail-type=NONE		                                  # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --time=20:00:00                                           # Time limit hrs:min:sec
#SBATCH --mem=4G	                                              # RAM required per node

set -- "${@:1}" "/home/dhl_ec/aligterink/PRSToolKit/prstoolkit.config"
# set -- "${@:1:2}" "/home/dhl_ec/aligterink/PRSToolKit/prstoolkit.config" "/hpc/dhl_ec/aligterink/ProjectFiles/UKBB.GWAS1KG.EXOME.CAD.SOFT.META.PublicRelease.300517.rsid.QCd.txt.gz"
# set -- "${@:1:2}" "/home/dhl_ec/aligterink/PRSToolKit/prstoolkit.config" "/hpc/dhl_ec/aligterink/ProjectFiles/tmpbase.txt"


# Setting colouring
NONE='\033[00m'
OPAQUE='\033[2m'
FLASHING='\033[5m'
BOLD='\033[1m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
STRIKETHROUGH='\033[9m'

RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'

### Regarding changing the 'type' of the things printed with 'echo'
### Refer to: 
### - http://askubuntu.com/questions/528928/how-to-do-underline-bold-italic-strikethrough-color-background-and-size-i
### - http://misc.flogisoft.com/bash/tip_colors_and_formatting
### - http://unix.stackexchange.com/questions/37260/change-font-in-echo-command

# Creating color-functions
function echobold { #'echobold' is the function name
    echo -e "${BOLD}${1}${NONE}" # this is whatever the function needs to execute, note ${1} is the text for echo
}
function echoitalic { 
    echo -e "${ITALIC}${1}${NONE}" 
}
function echonooption { 
    echo -e "${OPAQUE}${RED}${1}${NONE}"
}
function echoerrorflash { 
    echo -e "${RED}${BOLD}${FLASHING}${1}${NONE}" 
}
function echoerror { 
    echo -e "${RED}${1}${NONE}"
}
function echocyan { #'echobold' is the function name
    echo -e "${CYAN}${1}${NONE}" # this is whatever the function needs to execute.
}
function echoerrornooption { 
    echo -e "${YELLOW}${1}${NONE}"
}
function echoerrorflashnooption { 
    echo -e "${YELLOW}${BOLD}${FLASHING}${1}${NONE}"
}

script_copyright_message() {
	echo ""
	THISYEAR=$(date +'%Y')
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "+ The MIT License (MIT)                                                                                 +"
	echo "+ Copyright (c) 2016-${THISYEAR} Sander W. van der Laan                                                        +"
	echo "+                                                                                                       +"
	echo "+ Permission is hereby granted, free of charge, to any person obtaining a copy of this software and     +"
	echo "+ associated documentation files (the \"Software\"), to deal in the Software without restriction,         +"
	echo "+ including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, +"
	echo "+ and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, +"
	echo "+ subject to the following conditions:                                                                  +"
	echo "+                                                                                                       +"
	echo "+ The above copyright notice and this permission notice shall be included in all copies or substantial  +"
	echo "+ portions of the Software.                                                                             +"
	echo "+                                                                                                       +"
	echo "+ THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT     +"
	echo "+ NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND                +"
	echo "+ NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES  +"
	echo "+ OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN   +"
	echo "+ CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                            +"
	echo "+                                                                                                       +"
	echo "+ Reference: http://opensource.org.                                                                     +"
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}

script_arguments_error() {
	echoerror "$1" # Additional message
	echoerror "- Argument #1 is path_to/filename of the configuration file."
	# echoerror "- Argument #2 is path_to/filename of the list of GWAS summary statistics-files with arbitrarily chosen names, path_to, and file-names."
	echoerror ""
	echoerror "An example command would be: prstoolkit.sh [arg1]"
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
 	echo ""
	script_copyright_message
	exit 1
}

echobold "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "                          PRSToolKit: A TOOLKIT TO CALCULATE POLYGENIC SCORES"
echoitalic "                        --- prepare data and calculate polygenic scores ---"
echobold ""
echobold "* Version:      v1.0.1"
echobold ""
echobold "* Last update:  2021-04-07"
echobold "* Written by:   Sander W. van der Laan | s.w.vanderlaan@gmail.com"
echobold "				  Anton Ligterink | anton.ligterink@gmail.com"
echobold "* Description:  Prepare files and calculate polygenic scores. This tool will do the following:"
echobold "                - Perform quality control on GWAS summary data"
echobold "                - Calculate polygenic risk scores from GWAS summary statistcs (LDpred/PRSICE/RapidoPGS/PRScs)"
echobold "				  - Calculate polygenic scores using premade scoring systems (PLINK)"
echobold "* References:   RapidoPGS: https://cran.r-project.org/web/packages/RapidoPGS/vignettes/Computing_RapidoPGS.html"
echobold "                LDpred: https://github.com/bvilhjal/ldpred      PRSICE: https://www.prsice.info/"
echobold "                PRScs: https://github.com/getian107/PRScs       PLINK: http://zzz.bwh.harvard.edu/plink/"
echobold "* REQUIRED: "
echobold "  - A high-performance computer cluster with a SLURM system"
echobold "  - R v3.6+, Python 3.7+"
echobold "  - Required R 3.6+ modules: [RapidoPGS], [data.table], [optparse]"
echobold "  - Required Python 3.7+ modules: [pandas], [scipy], [numpy], [plinkio], [h5py]"
### ADD-IN: function to check requirements...
### This might be a viable option! https://gist.github.com/JamieMason/4761049
echobold ""
echobold "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Today's: "$(date)
TODAY=$(date +"%Y%m%d")

##########################################################################################
### SET THE SCENE FOR THE SCRIPT
##########################################################################################

##########################################################################################
### Command-line argument check
if [[ $# -lt 1 ]]; then 
	echo ""
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echoerrorflash "               *** Oh, oh, computer says no! Number of arguments found "$#". ***"
	echoerror "You must supply [1] argument when running *** PRSToolKit ***!"
	script_arguments_error
else
	echo "These are the "$#" arguments that passed:"
	echo "The configuration file..................: "$(basename ${1}) # argument 1
	# echo "The GWAS-files file.....................: "$(basename ${2}) # argument 2
fi 

##########################################################################################
### Loading command-line arguments and configuration file
source "$1" # Depends on arg1.
CONFIGURATIONFILE="$1" # Depends on arg1 -- but also on where it resides!!!
# BASEDATA="$2" # Depends on arg2 -- all the GWAS dataset information

##########################################################################################
### Set the output file name
OUTPUTNAME=${PROJECTNAME}_${PRSMETHOD}_$(date +%Y-%b-%d--%H-%M)_job_${SLURM_JOB_ID}

##########################################################################################
### Parameter validation
if [[ ${PRSMETHOD} == "PLINK" || ${PRSMETHOD} == "PRSCS" || ${PRSMETHOD} == "LDPRED" || ${PRSMETHOD} == "PRSICE" || ${PRSMETHOD} == "RAPIDOPGS" ]]; then
	echo ""
	echo "Calculating Polygenic Risk Scores using ${PRSMETHOD}."

elif [[ ${PRSMETHOD} == "MANUAL" ]]; then
	echo ""
	echoerrornooption "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echoerrornooption ""
	echoerrorflashnooption "               *** Oh, computer says no! This option is not available yet. ***"
	echoerrornooption "Unfortunately using [${PRSMETHOD}] as a PRS calculation method is not possible yet."
	echoerrornooption "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	### The wrong arguments are passed, so we'll exit the script now!
	echo ""
	script_copyright_message
	exit 1

else
	echo ""
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echoerror ""
	echoerrorflash "                  *** Oh, computer says no! Argument not recognised. ***"
	echoerror "You have the following options to calculate polygenic scores:"
	echoerror "LDPRED   -- use LDpred to LD-correct GWAS summary statistics and calculate polygenic scores [default]."
	echonooption "MANUAL   -- use an in-house developed Rscript to calculate a polygenic score using a limited set of variants."
	echonooption "PLINK    -- use PLINK to calculate scores, GWAS summary statistics will be LD-pruned using p-value thresholds (traditional approach, slow)."
	echonooption "PRSICE   -- use PRSice to calculate scores, GWAS summary statistics will be LD-pruned using p-value thresholds (new approach, fast)."
	echonooption "(Opaque: *not implemented yet*)"
	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	### The wrong arguments are passed, so we'll exit the script now!
	echo ""
	script_copyright_message
	exit 1
fi

##########################################################################################
### SETTING UP NECESSARY DIRECTORIES
echo ""
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Checking for the existence of the output directory [ ${OUTPUTDIRNAME} ]."
if [ ! -d ${PROJECTDIR}/${OUTPUTDIRNAME} ]; then
	echo "> Output directory doesn't exist - Mr. Bourne will create it for you."
	mkdir -v ${PROJECTDIR}/${OUTPUTDIRNAME}
else
	echo "> Output directory already exists."
fi
OUTPUTDIR=${PROJECTDIR}/${OUTPUTDIRNAME}

echo ""
echo "Checking for the existence of the subproject directory [ ${SUBPROJECT_DIR_NAME} ]."
if [ ! -d ${OUTPUTDIR}/${SUBPROJECT_DIR_NAME} ]; then
	echo "> Subproject directory doesn't exist - Mr. Bourne will create it for you."
	mkdir -v ${OUTPUTDIR}/${SUBPROJECT_DIR_NAME}
else
	echo "> Subproject directory already exists."
fi
SUBPROJECTDIR=${OUTPUTDIR}/${SUBPROJECT_DIR_NAME}

echo ""
echo "Checking for the existence of the ${LOG_DIR_NAME} directory [ ${PROJECTDIR}/${LOG_DIR_NAME} ]."
if [ ! -d ${PROJECTDIR}/${LOG_DIR_NAME} ]; then
	echo "> ${LOG_DIR_NAME} directory doesn't exist - Mr. Bourne will create it for you."
	mkdir -v ${PROJECTDIR}/${LOG_DIR_NAME}
else
	echo "> ${LOG_DIR_NAME} directory already exists."
fi
LOGDIR=${PROJECTDIR}/${LOG_DIR_NAME}

echo ""
echo "Checking for the existence of the main working directory [ ${PROJECTDIR}/${MAIN_WORKDIR_NAME} ]."
if [ ! -d ${PROJECTDIR}/${MAIN_WORKDIR_NAME} ]; then
	echo "> ${MAIN_WORKDIR_NAME} directory doesn't exist - Mr. Bourne will create it for you."
	mkdir -v ${PROJECTDIR}/${MAIN_WORKDIR_NAME}
else
	echo "> ${MAIN_WORKDIR_NAME} directory already exists."
fi
MAIN_WORKDIR=${PROJECTDIR}/${MAIN_WORKDIR_NAME}

echo ""
echo "Checking for the existence of the working directory for this project [ ${MAIN_WORKDIR}/${OUTPUTNAME} ]."
if [ ! -d ${MAIN_WORKDIR}/${OUTPUTNAME} ]; then
	echo "> ${OUTPUTNAME} doesn't exist - Mr. Bourne will create it for you."
	mkdir -v ${MAIN_WORKDIR}/${OUTPUTNAME}
else
	echo "> ${OUTPUTNAME} already exists."
fi
PRSDIR=${MAIN_WORKDIR}/${OUTPUTNAME}

echo ""
echo "The scene is properly set, and directories are created! 🖖"
echo "PRSToolKit directory............................................: "${PRSTOOLKITDIR}
echo "LD reference data directory.....................................: "${LDDATA}
echo "Validation data directory.......................................: "${VALIDATIONDATA}
echo "Main directory..................................................: "${PROJECTDIR}
echo "Main analysis output directory..................................: "${OUTPUTDIR}
echo "Subproject's analysis output directory..........................: "${SUBPROJECTDIR}
echo "Log directory...................................................: "${LOGDIR}
echo "Main working directory..........................................: "${MAIN_WORKDIR}
echo "Working directory for this project..............................: "${PRSDIR}
echo ""
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

QC_DEPENDENCY=""
if [[ ${QC} == "YES" ]]; then

	echo ""
	echobold "#========================================================================================================"
	echobold "#== OPTIONAL QUALITY CONTROL IS IN EFFECT [DEFAULT]"
	echobold "#========================================================================================================"
	echobold "#"
	echo ""
	echo "We will perform quality control on the base dataset, using the following thresholds:"
	echo "      Minor allele frequency: ${MAF}"
	echo "      Imputation score:       ${INFO}"

	# Start the quality control job
	QC_SUMMARY_FILE=${PRSDIR}/${OUTPUTNAME}_QC_results.txt
	QC_OUTPUT=${PRSDIR}/QCd_basefile.txt.gz
	# QC_JOBID=$(sbatch --parsable --wait --job-name=PRS_QC --time ${RUNTIME_QC} --mem ${MEMORY_QC} -o ${LOGDIR}/${OUTPUTNAME}_QC.log ${PRSTOOLKITSCRIPTS}/QC.R -b ${BASEDATA} -s ${STATS_FILE} -o ${PRSDIR}/QCd_basefile.txt.gz -m ${MAF} -i ${INFO} -a ${BF_ID_COL} -d ${STATS_ID_COL} -c ${STATS_MAF_COL} -t ${STATS_INFO_COL} -r ${QC_SUMMARY_FILE})
	QC_JOBID=$(sbatch --parsable --wait --job-name=PRS_QC --time ${RUNTIME_QC} --mem ${MEMORY_QC} -o ${LOGDIR}/${OUTPUTNAME}_QC.log ${PRSTOOLKITSCRIPTS}/QC.py -b ${BASEDATA} -i ${BF_ID_COL} -s ${STATS_FILE} -a ${STATS_ID_COL} -c ${STATS_MAF_COL} -d ${STATS_INFO_COL} -m ${MAF} -n ${INFO} -o ${QC_OUTPUT} -r ${QC_SUMMARY_FILE})
	QC_DEPENDENCY="--dependency=afterok:${QC_JOBID}"

	echo ""
	cat ${QC_SUMMARY_FILE}
	echo ""

	# We will now use the quality controlled file as our new base file
	BASEDATA=QC_OUTPUT

elif [[ ${QC} == "NO" ]]; then
	echo ""
	echo "Quality control will not be performed"
	echo ""
else 
	echo ""
	echo "QC parameter should be [YES/NO], not \"${QC}\". Exiting..."
	echo ""
	exit 1
fi

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo ""
echo "Risk score computation will now commence."
echo ""

RESULTS_FILE=${SUBPROJECTDIR}/${OUTPUTNAME}_results.txt

##########################################################################################
### Run the individual PRS method scripts

if [[ ${PRSMETHOD} == "PLINK" ]]; then

	# Calculate the effect sizes for each chromosome
	### TODO: make this run in parallel and make it prettier
	PLINK_HEADER="header"
	PLINKSCORE_JOBID=$(sbatch --parsable --wait --job-name=PRS_PLINKSCORE ${QC_DEPENDENCY} --time ${RUNTIME_PLINKSCORE} --mem ${MEMORY_PLINKSCORE} -o ${LOGDIR}/${OUTPUTNAME}_PLINK_score.log --export=ALL,VALIDATIONDATA=${VALIDATIONDATA},VALIDATIONPREFIX=${VALIDATIONPREFIX},PLINK=${PLINK},REF_POS=${BF_REF_POS},SAMPLE_FILE=${SAMPLE_FILE},PRSDIR=${PRSDIR},WEIGHTS_FILE=${BASEDATA},SNP_COL=${BF_SNP_COL},EFFECT_COL=${BF_EFFECT_COL},SCORE_COL=${BF_STAT_COL},PLINK_SETTINGS=${PLINK_SETTINGS},PLINK_HEADER=${PLINK_HEADER} ${PRSTOOLKITSCRIPTS}/plinkscore.sh)
	PLINKSCORE_DEPENDENCY="--dependency=afterok:${PLINKSCORE_JOBID}"

	# Sum the effect sizes to calculate the final score
	PLINKSUM_JOBID=$(sbatch --parsable --wait --job-name=PRS_PLINKSUM ${PLINKSCORE_DEPENDENCY} --time ${RUNTIME_PLINKSUM} --mem ${MEMORY_PLINKSUM} -o ${LOGDIR}/${OUTPUTNAME}_PLINK_sum.log ${PRSTOOLKITSCRIPTS}/sum_plink_scores.R -s ${SAMPLE_FILE} -f 1 -i 2 -d ${PRSDIR} -p plink2_${VALIDATIONPREFIX} -a 1 -b 2 -r 6 -o ${RESULTS_FILE})

elif [[ ${PRSMETHOD} == "PRSCS" ]]; then

	# Parse the base file to PRS-CS format (and also unzip it)
	PARSED_BASEDATA=${PRSDIR}/basefile_PRScs_format.txt
	PRSCS_format_JOBID=$(sbatch --parsable --wait --job-name=PRS_PRScs_format ${QC_DEPENDENCY} --time ${RUNTIME_PRSCS_format} --mem ${MEMORY_PRSCS_format} -o ${LOGDIR}/${OUTPUTNAME}_PRScs_format.log ${PRSTOOLKITSCRIPTS}/basefile_PRScs_formatter.R -i ${BASEDATA} -o ${PARSED_BASEDATA} -d ${BF_ID_COL} -r ${BF_EFFECT_COL} -a ${BF_NON_EFFECT_COL} -z ${BF_STAT} -m ${BF_STAT_COL} -v ${BF_PVALUE_COL})
	PRSCS_format_DEPENDENCY="--dependency=afterok:${PRSCS_format_JOBID}"

	PARSED_BASEDATA="/hpc/dhl_ec/aligterink/ProjectFiles/tmp/CAD_PRSCS_2021-Apr-25--16-31_job_4742573/basefile_PRScs_format.txt"
	WEIGHTS_FILE=${PRSDIR}/PRScs_weights

	PRSCS_JOBID=$(sbatch --parsable --wait --job-name=PRS_PRScs ${PRSCS_format_DEPENDENCY} --time ${RUNTIME_PRSCS} --mem ${MEMORY_PRSCS} -o ${LOGDIR}/${OUTPUTNAME}_PRScs.log --export=ALL,VALIDATIONDATA=${VALIDATIONDATA},VALIDATIONPREFIX=${VALIDATIONPREFIX},SAMPLE_FILE=${SAMPLE_FILE},BIM_FILE_AVAILABLE=${BIM_FILE_AVAILABLE},BIM_FILE_PATH=${BIM_FILE_PATH},PRSDIR=${PRSDIR},BF_REF_POS=${BF_REF_POS},BF_SAMPLE_SIZE=${BF_SAMPLE_SIZE},PLINK=${PLINK},PYTHONPATH=${PYTHONPATH},LDDATA=${LDDATA},PRSCS=${PRSCS},PARSED_BASEDATA=${PARSED_BASEDATA},WEIGHTS_FILE=${WEIGHTS_FILE} ${PRSTOOLKITSCRIPTS}/prscs.sh)
	PRSCS_DEPENDENCY="--dependency=afterok:${PLINKSCORE_JOBID}"

	# Calculate individual scores using PLINK
	PLINK_HEADER=""
	PLINKSCORE_JOBID=$(sbatch --parsable --wait --job-name=PRS_PLINKSCORE ${PRSCS_DEPENDENCY} --time ${RUNTIME_PLINKSCORE} --mem ${MEMORY_PLINKSCORE} -o ${LOGDIR}/${OUTPUTNAME}_PLINK_score.log --export=ALL,VALIDATIONDATA=${VALIDATIONDATA},VALIDATIONPREFIX=${VALIDATIONPREFIX},PLINK=${PLINK},REF_POS=${BF_REF_POS},SAMPLE_FILE=${SAMPLE_FILE},PRSDIR=${PRSDIR},WEIGHTS_FILE=${WEIGHTS_FILE},SNP_COL=SNPID,EFFECT_COL=REF,SCORE_COL=WEIGHT,PLINK_SETTINGS=${PLINK_SETTINGS},PLINK_HEADER=${PLINK_HEADER} ${PRSTOOLKITSCRIPTS}/plinkscore.sh)
	PLINKSCORE_DEPENDENCY="--dependency=afterok:${PLINKSCORE_JOBID}"

	# # Sum the effect sizes to calculate the final score
	PLINKSUM_JOBID=$(sbatch --parsable --wait --job-name=PRS_PLINKSUM ${PLINKSCORE_DEPENDENCY} --time ${RUNTIME_PLINKSUM} --mem ${MEMORY_PLINKSUM} -o ${LOGDIR}/${OUTPUTNAME}_PLINK_sum.log ${PRSTOOLKITSCRIPTS}/sum_plink_scores.R -s ${SAMPLE_FILE} -f 1 -i 2 -d ${PRSDIR} -p plink2_${VALIDATIONPREFIX} -a 1 -b 2 -r 6 -o ${RESULTS_FILE})

elif [[ ${PRSMETHOD} == "LDPRED" ]]; then
	cd ${PRSDIR}
	LDPRED_JOBID=$(sbatch --parsable --wait --job-name=PRS_LDPRED ${QC_DEPENDENCY} --time ${RUNTIME_LDPRED} --mem ${MEMORY_LDPRED} -o ${LOGDIR}/${OUTPUTNAME}_LDPRED.log ${PRSTOOLKITSCRIPTS}/LDpred2.R)
	# echo "not implemented"


elif [[ ${PRSMETHOD} == "PRSICE" ]]; then
	PRSICE_OUTPUTNAME=${PRSDIR}/out
	PRSICE_JOBID=$(sbatch --parsable --wait --job-name=PRS_PRSICE ${QC_DEPENDENCY} --time ${RUNTIME_PRSICE} --mem ${MEMORY_PRSICE} -o ${LOGDIR}/${OUTPUTNAME}_PRSICE.log --export=ALL,RSCRIPT=${RSCRIPT},PRSICE2_R=${PRSICE2_R},PRSICE2_SH=${PRSICE2_SH},PRSDIR=${PRSDIR},PRSICE_BARLEVELS=${PRSICE_BARLEVELS},BASEDATA=${BASEDATA},TARGETDATA=${TARGETDATA},PRSICE_THREADS=${PRSICE_THREADS},BF_STAT=${BF_STAT},BF_TARGET_TYPE=${BF_TARGET_TYPE},BF_ID_COL=${BF_ID_COL},BF_CHR_COL=${BF_CHR_COL},BF_POS_COL=${BF_POS_COL},BF_EFFECT_COL=${BF_EFFECT_COL},BF_NON_EFFECT_COL=${BF_NON_EFFECT_COL},BF_STAT_COL=${BF_STAT_COL},BF_PVALUE_COL=${BF_PVALUE_COL},PHENOTYPEFILE=${SAMPLE_FILE},DUMMY_PHENOTYPE=${DUMMY_PHENOTYPE},PRSICE_PLOTTING="${PRSICE_PLOTTING}",PRSICE_SETTINGS="${PRSICE_SETTINGS}",PRSICE_OUTPUTNAME=${PRSICE_OUTPUTNAME} ${PRSTOOLKITSCRIPTS}/prsice.sh)
	echo "sbatch --parsable --wait --job-name=PRS_PRSICE ${QC_DEPENDENCY} --time ${RUNTIME_PRSICE} --mem ${MEMORY_PRSICE} -o ${LOGDIR}/${OUTPUTNAME}_PRSICE.log --export=ALL,RSCRIPT=${RSCRIPT},PRSICE2_R=${PRSICE2_R},PRSICE2_SH=${PRSICE2_SH},PRSDIR=${PRSDIR},PRSICE_BARLEVELS=${PRSICE_BARLEVELS},BASEDATA=${BASEDATA},TARGETDATA=${TARGETDATA},PRSICE_THREADS=${PRSICE_THREADS},BF_STAT=${BF_STAT},BF_TARGET_TYPE=${BF_TARGET_TYPE},BF_ID_COL=${BF_ID_COL},BF_CHR_COL=${BF_CHR_COL},BF_POS_COL=${BF_POS_COL},BF_EFFECT_COL=${BF_EFFECT_COL},BF_NON_EFFECT_COL=${BF_NON_EFFECT_COL},BF_STAT_COL=${BF_STAT_COL},BF_PVALUE_COL=${BF_PVALUE_COL},PHENOTYPEFILE=${SAMPLE_FILE},DUMMY_PHENOTYPE=${DUMMY_PHENOTYPE},PRSICE_PLOTTING="${PRSICE_PLOTTING}",PRSICE_SETTINGS="${PRSICE_SETTINGS}",PRSICE_OUTPUTNAME=${PRSICE_OUTPUTNAME} ${PRSTOOLKITSCRIPTS}/prsice.sh"

elif [[ ${PRSMETHOD} == "RAPIDOPGS" ]]; then

	# File for storing the effect sizes computed by Rapido
	WEIGHTS_FILE="${PRSDIR}/Rapido_weights.txt"

	# Calculate weights using RapidoPGS
	RAPIDO_JOBID=$(sbatch --parsable --wait --job-name=PRS_RAPIDO ${QC_DEPENDENCY} --time ${RUNTIME_RAPIDO} --mem ${MEMORY_RAPIDO} -o ${LOGDIR}/${OUTPUTNAME}_RAPIDO.log ${PRSTOOLKITSCRIPTS}/rapidopgs.R -k ${PRSDIR} -o ${WEIGHTS_FILE} -b ${BASEDATA} -d ${BF_BUILD} -i ${BF_SNP_COL} -c ${BF_CHR_COL} -p ${BF_POS_COL} -r ${BF_NON_EFFECT_COL} -a ${BF_EFFECT_COL} -f ${BF_FRQ_COL} -w ${BF_WFRQ} -m ${BF_STAT_COL} -e ${BF_SE_COL} -s ${BF_SAMPLE_SIZE} -l ${RP_trait})
	RAPIDO_DEPENDENCY="--dependency=afterok:${RAPIDO_JOBID}"
	
	# Calculate individual scores using PLINK
	PLINK_HEADER="header"
	PLINKSCORE_JOBID=$(sbatch --parsable --wait --job-name=PRS_PLINKSCORE ${RAPIDO_DEPENDENCY} --time ${RUNTIME_PLINKSCORE} --mem ${MEMORY_PLINKSCORE} -o ${LOGDIR}/${OUTPUTNAME}_PLINK_score.log --export=ALL,VALIDATIONDATA=${VALIDATIONDATA},VALIDATIONPREFIX=${VALIDATIONPREFIX},PLINK=${PLINK},REF_POS=${BF_REF_POS},SAMPLE_FILE=${SAMPLE_FILE},PRSDIR=${PRSDIR},WEIGHTS_FILE=${WEIGHTS_FILE},SNP_COL=SNPID,EFFECT_COL=REF,SCORE_COL=WEIGHT,PLINK_SETTINGS=${PLINK_SETTINGS},PLINK_HEADER=${PLINK_HEADER} ${PRSTOOLKITSCRIPTS}/plinkscore.sh)
	PLINKSCORE_DEPENDENCY="--dependency=afterok:${PLINKSCORE_JOBID}"

	# Sum the effect sizes to calculate the final score
	PLINKSUM_JOBID=$(sbatch --parsable --wait --job-name=PRS_PLINKSUM ${PLINKSCORE_DEPENDENCY} --time ${RUNTIME_PLINKSUM} --mem ${MEMORY_PLINKSUM} -o ${LOGDIR}/${OUTPUTNAME}_PLINK_sum.log ${PRSTOOLKITSCRIPTS}/sum_plink_scores.R -s ${SAMPLE_FILE} -f 1 -i 2 -d ${PRSDIR} -p plink2_${VALIDATIONPREFIX} -a 1 -b 2 -r 6 -o ${RESULTS_FILE})

fi

echo ""
echo "${PRSMETHOD} risk score calculation has finished."
echo ""

if [[ ${KEEP_TEMP_FILES} == "YES" ]]; then
	echo "KEEP_TEMP_FILES parameter is active, temporary files stored in [ ${PRSDIR} ] will not be removed."

elif [[ ${KEEP_TEMP_FILES} == "NO" ]]; then
	echo "KEEP_TEMP_FILES parameter is inactive, temporary files stored in [ ${PRSDIR} ] will now be removed."
	### TODO: insert delete function here

else
	echo "KEEP_TEMP_FILES parameter not recognized, temporary files stored in [ ${PRSDIR} ] will not be removed."

fi

echo ""
echocyan "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "Wow. I'm all done buddy. What a job 😱 ! let's have a 🍻🍻 ... 🖖 "

# script_copyright_message











# if [[ ${VALIDATIONFORMAT} == "VCF" ]]; then
# 	echo ""
# 	echo "The validation dataset is encoded in the [${VALIDATIONFORMAT}] file-format; PRSToolKit will procede "
# 	echo "immediately after optional QC."

# elif [[ ${VALIDATIONFORMAT} == "OXFORD" || ${VALIDATIONFORMAT} == "PLINK" ]]; then

# 	echoerrornooption "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# 	echoerrornooption ""
# 	echoerrorflashnooption "               *** Oh, computer says no! This option is not available yet. ***"
# 	echoerrornooption "Unfortunately the [${VALIDATIONFORMAT}] file-format is not supported."
# 	echoerrornooption "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# 	### The wrong arguments are passed, so we'll exit the script now!
# 	echo ""
# 	script_copyright_message
# 	exit 1
	
# else
# 	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# 	echoerror ""
# 	echoerrorflash "                  *** Oh, computer says no! Argument not recognised. ***"
# 	echoerror "You can indicate the following validation file-formats:"
# 	echoerror "OXFORD   -- file format used by IMPUTE2 (.gen/.bgen) [default]."
# 	echonooption "VCF   -- VCF file format, version 4.2 is expected."
# 	echoerror "PLINK    -- PLINK file format; PRSToolKit can immediately use this."
# 	echonooption "(Opaque: *not implemented yet*)"
# 	echoerror "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# 	### The wrong arguments are passed, so we'll exit the script now!
# 	echo ""
# 	script_copyright_message
# 	exit 1
# fi
##########################################################################################
### SETTING DIRECTORIES (from configuration file).

# # Where PRSToolKit resides
# PRSTOOLKITDIR=${PRSTOOLKITDIR} # from configuration file

# # Data information
# LDDATA=${LDDATA} # from configuration file
# VALIDATIONDATA="${VALIDATIONDATA}/${VALIDATIONFILE}" # from configuration file





# 	if [[ ${VALIDATIONQC} == "YES" ]]; then

# 		echo ""
# 		echobold "#========================================================================================================"
# 		echobold "#== OPTIONAL VALIDATION QUALITY CONTROL IS IN EFFECT [DEFAULT]"
# 		echobold "#========================================================================================================"
# 		echobold "#"
# 		echo ""
# 		echo "We will perform quality control on the validation dataset [${VALIDATIONNAME}] which is in [${VALIDATIONFORMAT}]-format."
	
# 		### Example head of STATS-file 15 16 19
# 		### SNPID RSID Chr BP A_allele B_allele MinorAllele MajorAllele AA AB BB AA_calls AB_calls BB_calls MAF HWE missing missing_calls Info CAF
# 		### --- 1:10177:A:AC 01 10177 A AC AC A 554.34 731.78 239.87 46 56 8 0.39696 0.018899 6.3195e-06 0.92792 0.35024 0.396962
# 		### --- 1:10235:T:TA 01 10235 T TA TA T 1524.2 1.8055 0 1523 0 0 0.00059159 4.8216e-17 0 0.0019659 0.26078 0.000591577
# 		### --- rs145072688:10352:T:TA 01 10352 T TA TA T 490.88 755.85 279.26 46 55 15 0.43066 0.14578 1.0239e-05 0.92398 0.34431 0.430661
# 		### --- 1:10505:A:T 01 10505 A T T A 1525.7 0.34198 0 1525 0 0 0.00011205 -0 0 0.00065531 0.2532 0.000112048
# # 		
# # 		echo "SNPID RSID Chr BP alleleA alleleB HWE Info CAF" > ${SUBPROJECTDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.keep.txt
# # 		zcat ${VALIDATIONDATA}/aegs_combo_1kGp3GoNL5_RAW.stats.gz | tail -n +2 | awk ' $15 > '$MAF' && $16 > '$HWE' && $19 > '$INFO' ' >> ${SUBPROJECTDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.keep.txt
# # 		
# # 		cat ${SUBPROJECTDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.keep.txt | awk '{ print $2 }' > ${SUBPROJECTDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.keeptofilter.txt
# # 		
# 		for CHR in $(seq 1 22) X; do 
# 		### FOR DEBUGGING
# 		### for CHR in 22; do
		
# 			echo ""
# 			echo "* processing chromosome ${CHR} and extracting relevant variants."
# 			echo "${QCTOOL} -g ${VALIDATIONDATA}/${VALIDATIONFILE}${CHR}.gen.gz -s ${VALIDATIONDATA}/${VALIDATIONFILE}${CHR}.sample -excl-rsids ${SUBPROJECTDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.keeptofilter.txt -og ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR}.gen -os ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR}.sample" > ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR}.filter.sh
# 			qsub -S /bin/bash -N PRS.FILTER.${VALIDATIONNAME}.chr${CHR} -o ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR}.filter.log -e ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR}.filter.errors -l h_vmem=${QMEMFILTER} -l h_rt=${QRUNTIMEFILTER} -wd ${PARSEDDIR} ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR}.filter.sh
		
# 			echo ""
# 			echo "* converting to PLINK-binary format."
# 			echo "${QCTOOL} -g ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR}.gen -s ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR}.sample -threshhold ${THRESHOLD} -og ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR} -ofiletype binary_ped" > ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR}.convert.sh
# 			qsub -S /bin/bash -N PRS.CONVERT.${VALIDATIONNAME}.chr${CHR} -hold_jid PRS.FILTER.${VALIDATIONNAME}.chr${CHR} -o ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR}.convert.log -e ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR}.convert.errors -l h_vmem=${QMEMCONVERT} -l h_rt=${QRUNTIMECONVERT} -wd ${PARSEDDIR} ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR}.convert.sh
		
# 			echo ""
# 			echo "* deleting old files."
# 			echo "rm -v ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR}.gen ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR}.sample" > ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR}.clean.sh
# 			qsub -S /bin/bash -N PRS.CLEAN.${VALIDATIONNAME}.chr${CHR} -hold_jid PRS.CONVERT.${VALIDATIONNAME}.chr${CHR} -o ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR}.clean.log -e ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR}.clean.errors -l h_vmem=${QMEM} -l h_rt=${QRUNTIME} -wd ${PARSEDDIR} ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR}.clean.sh
		
# 		done

# 	elif [[ ${VALIDATIONQC} == "NO" ]]; then

# 		echo ""
# 		echobold "#========================================================================================================"
# 		echobold "#== PARSING DATA TO PLINK-BINARY FORMAT"
# 		echobold "#========================================================================================================"
# 		echobold "#"
# 		echo ""
# 		echo "We will parse the validation dataset [${VALIDATIONNAME}], which is in [${VALIDATIONFORMAT}]-format, to PLINK-binary format."
	
# 		for CHR in $(seq 1 22) X; do 
# 		### FOR DEBUGGING
# 		### for CHR in 22; do
		
# 			echo ""
# 			echo "* processing chromosome ${CHR} and converting to PLINK-binary format."
# 			echo "${QCTOOL} -g ${VALIDATIONDATA}/${VALIDATIONFILE}${CHR}.gen.gz -s ${VALIDATIONDATA}/${VALIDATIONFILE}${CHR}.sample -threshhold ${THRESHOLD} -og ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR} -ofiletype binary_ped" > ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR}.convert.sh
# 			qsub -S /bin/bash -N PRS.CONVERT.${VALIDATIONNAME}.chr${CHR} -o ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR}.convert.log -e ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR}.convert.errors -l h_vmem=${QMEMCONVERT} -l h_rt=${QRUNTIMECONVERT} -wd ${PARSEDDIR} ${PARSEDDIR}/${VALIDATIONNAME}.${POPULATION}.${REFERENCE}.chr${CHR}.convert.sh
		
# 		done
	
# 	fi

# 






# 	echobold "#========================================================================================================"
# 	echobold "#== VALIDATION QUALITY CONTROL"
# 	echobold "#========================================================================================================"
# 	echobold "#"
# 	### REQUIRED: VEGAS/VEGAS2 settings.
# 	### Note: we do `cd ${VEGASDIR}` because VEGAS is making temp-files in a special way, 
# 	###       adding a date-based number in front of the input/output files.
# 	echo "Creating VEGAS input files..." 
# 	mkdir -v ${SUBPROJECTDIR}/vegas
# 	VEGASRESULTDIR=${SUBPROJECTDIR}/vegas
# 	chmod -Rv a+rwx ${VEGASRESULTDIR}
# 	echo "...per chromosome."

# 	while IFS='' read -r GWASCOHORT || [[ -n "$GWASCOHORT" ]]; do
# 			LINE=${GWASCOHORT}
# 			COHORT=$(echo "${LINE}" | awk '{ print $1 }')
# 			echo "     * ${COHORT}"
		
# 			if [ ! -d ${VEGASRESULTDIR}/${COHORT} ]; then
# 				echo "> VEGAS results directory doesn't exist - Mr. Bourne will create it for you."
# 				mkdir -v ${VEGASRESULTDIR}/${COHORT}
# 				chmod -Rv a+rwx ${VEGASRESULTDIR}/${COHORT}
# 			else
# 				echo "> VEGAS results directory already exists."
# 				chmod -Rv a+rwx ${VEGASRESULTDIR}/${COHORT}
# 			fi

# 		for CHR in $(seq 1 23); do
# 			if [[ $CHR -le 22 ]]; then 
# 				echo "Processing chromosome ${CHR}..."
# 				echo "zcat ${PARSEDDIR}/${COHORT}/${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.FINAL.txt.gz | ${SCRIPTS}/parseTable.pl --col ${VARIANTID},CHR,P | awk ' \$2==${CHR} ' | awk '{ print \$1, \$3 }' | tail -n +2 > ${VEGASRESULTDIR}/${COHORT}/${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.forVEGAS.txt " > ${VEGASRESULTDIR}/${COHORT}/${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.createVEGAS.sh
# # 				qsub -S /bin/bash -N VEGAS2.${PROJECTNAME}.chr${CHR}.create -hold_jid gwas.wrapper -o ${VEGASRESULTDIR}/${COHORT}/${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.createVEGAS.log -e ${VEGASRESULTDIR}/${COHORT}/${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.createVEGAS.errors -l h_vmem=${QMEMVEGAS} -l h_rt=${QRUNTIMEVEGAS} -wd ${VEGASRESULTDIR} ${VEGASRESULTDIR}/${COHORT}/${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.createVEGAS.sh
			
# 				echo "cd ${VEGASRESULTDIR}/${COHORT} " > ${VEGASRESULTDIR}/${COHORT}/${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
# 				echo "$VEGAS2 -G -snpandp ${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.forVEGAS.txt -custom ${VEGAS2POP}.chr${CHR} -glist ${VEGAS2GENELIST} -upper ${VEGAS2UPPER} -lower ${VEGAS2LOWER} -chr ${CHR} -out ${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.fromVEGAS " >> ${VEGASRESULTDIR}/${COHORT}/${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
# # 				qsub -S /bin/bash -N VEGAS2.${PROJECTNAME}.chr${CHR} -hold_jid VEGAS2.${PROJECTNAME}.chr${CHR}.create -o ${VEGASRESULTDIR}/${COHORT}/${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.log -e ${VEGASRESULTDIR}/${COHORT}/${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.errors -l h_vmem=${QMEMVEGAS} -l h_rt=${QRUNTIMEVEGAS} -wd ${VEGASRESULTDIR} ${VEGASRESULTDIR}/${COHORT}/${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
	
# 			elif [[ $CHR -eq 23 ]]; then  
# 				echo "Processing chromosome X..."
# 				echo "zcat ${PARSEDDIR}/${COHORT}/${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.FINAL.txt.gz | ${SCRIPTS}/parseTable.pl --col ${VARIANTID},CHR,P | awk ' \$2==\"X\" ' | awk '{ print \$1, \$3 }' | tail -n +2 > ${VEGASRESULTDIR}/${COHORT}/${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.forVEGAS.txt " > ${VEGASRESULTDIR}/${COHORT}/${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.createVEGAS.sh
# # 				qsub -S /bin/bash -N VEGAS2.${PROJECTNAME}.chr${CHR}.create -hold_jid gwas.wrapper -o ${VEGASRESULTDIR}/${COHORT}/${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.createVEGAS.log -e ${VEGASRESULTDIR}/${COHORT}/${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.createVEGAS.errors -l h_vmem=${QMEMVEGAS} -l h_rt=${QRUNTIMEVEGAS} -wd ${VEGASRESULTDIR} ${VEGASRESULTDIR}/${COHORT}/${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.createVEGAS.sh
			
# 				echo "cd ${VEGASRESULTDIR}/${COHORT} " > ${VEGASRESULTDIR}/${COHORT}/${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
# 				echo "$VEGAS2 -G -snpandp ${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.forVEGAS.txt -custom ${VEGAS2POP}.chr${CHR} -glist ${VEGAS2GENELIST} -upper ${VEGAS2UPPER} -lower ${VEGAS2LOWER} -chr ${CHR} -out ${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.fromVEGAS " >> ${VEGASRESULTDIR}/${COHORT}/${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
# # 				qsub -S /bin/bash -N VEGAS2.${PROJECTNAME}.chr${CHR} -hold_jid VEGAS2.${PROJECTNAME}.chr${CHR}.create -o ${VEGASRESULTDIR}/${COHORT}/${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.log -e ${VEGASRESULTDIR}/${COHORT}/${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.errors -l h_vmem=${QMEMVEGAS} -l h_rt=${QRUNTIMEVEGAS} -wd ${VEGASRESULTDIR} ${VEGASRESULTDIR}/${COHORT}/${COHORT}.${PROJECTNAME}.${REFERENCE}.${POPULATION}.chr${CHR}.runVEGAS.sh
	
# 			else
# 				echo "*** ERROR *** Something is rotten in the City of Gotham; most likely a typo. Double back, please."	
# 				exit 1
# 			fi

# 		done
# 	done < ${BASEDATA}
#
	

