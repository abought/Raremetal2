#!/usr/bin/env bash

#####
# If calling from another script, can pass the following environment variables to control behavior:
#  EXE - Path to the raremetalworker binary
#  BASE_DIR - Relative path from where the script is called to the base repository directory
#  TEST_DIR - Where to find these tests
#
# If  may be useful to override these variables, though less often needed.
#  RESULTS_ACTUAL_DIR - where to store the calculated results files generated during a run of this script
#  RESULTS_EXPECTED_DIR - where to find the expected results associated with this test suite
#####

# Stop if any test fails, and always print the commands as they are run
set -e
set -x

#########################
# Common configuration
#########################
BASE_DIR=${BASE_DIR:-../..}

# Some internal default values
_DEFAULT_EXE=${BASE_DIR}/bin/raremetalworker
_DEFAULT_TEST_DIR=${BASE_DIR}/raremetalworker/test

# Values to override
EXE=${EXE:-$_DEFAULT_EXE}
TEST_DIR=${TEST_DIR:-$_DEFAULT_TEST_DIR}
DATA_DIR=${BASE_DIR}/data

RESULTS_ACTUAL_DIR=${TEST_DIR}/results_actual  # Where are the actual calculated results for this test run stored?
RESULTS_EXPECTED_DIR=${DATA_DIR}/tests/results_expected  # Where are the expected outputs stored, for comparison to this run?

# User-defined function: check whether all expected output files match the expected inputs
verify_results() {
    # Expect 2 single-arguments plus an array: expected_foldername[str], actual_foldername[str], (...filenames[array])
    expected_foldername=$1
    actual_foldername=$2
    filenames=${@:3}
    for i in ${filenames[@]}; do
        diff "$expected_foldername/$i" "$actual_foldername/$i"
    done
}

#########################
# Initial setup
#########################
TUT_DIR=${DATA_DIR}/raremetal_tutorial  # Where to extract tutorial files
if [ ! -e $TUT_DIR ]; then
    tar xvzf ${DATA_DIR}/Raremetal_tutorial.tar.gz --directory ${DATA_DIR}
fi

# Make sure that results folder exists for calculations
mkdir -p $RESULTS_ACTUAL_DIR

###################################################################################
# Test 1a: The Raremetal tutorial data (first study) returns the expected results
###################################################################################
#  http://genome.sph.umich.edu/wiki/Tutorial:_RAREMETAL
TUTORIAL_RESULTS_DIR=${RESULTS_EXPECTED_DIR}/tutorial

$EXE --ped "${TUT_DIR}/example1.ped" --dat "${TUT_DIR}/example1.dat" --vcf "${TUT_DIR}/example1.vcf.gz" --traitName QT1 \
                  --inverseNormal --makeResiduals --kinSave --kinGeno --prefix "${RESULTS_ACTUAL_DIR}/STUDY1"

# Output files must exist, and match the expected content (skip files that contain mutable fields like dates)
expect_outputs=("STUDY1.QT1.singlevar.score.txt" "STUDY1.QT1.singlevar.cov.txt" "STUDY1.Empirical.Kinship.gz")
verify_results ${TUTORIAL_RESULTS_DIR} ${RESULTS_ACTUAL_DIR} ${expect_outputs[@]}


##################################################
# Test 1b: The Raremetal tutorial (second study)
##################################################
$EXE --ped "${TUT_DIR}/example2.ped" --dat "${TUT_DIR}/example2.dat" --vcf "${TUT_DIR}/example2.vcf.gz" --traitName QT1 \
                  --inverseNormal --makeResiduals --kinSave --kinGeno --prefix "${RESULTS_ACTUAL_DIR}/STUDY2"

# Output files must exist, and match the expected content (skip files that contain mutable fields like dates)
expect_outputs=("STUDY2.QT1.singlevar.score.txt" "STUDY2.QT1.singlevar.cov.txt" "STUDY2.Empirical.Kinship.gz")
verify_results ${TUTORIAL_RESULTS_DIR} ${RESULTS_ACTUAL_DIR} ${expect_outputs[@]}


#### Print a message when all tests completed
echo "All tests completed successfully"