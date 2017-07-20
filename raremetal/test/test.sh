#!/usr/bin/env bash

#####
# If calling from another script, can pass the following environment variables to control behavior:
#  EXE - Path to the raremetal binary
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
_DEFAULT_EXE=${BASE_DIR}/bin/raremetal
_DEFAULT_TEST_DIR=${BASE_DIR}/raremetal/test

# Values to override
EXE=${EXE:-$_DEFAULT_EXE}
TEST_DIR=${TEST_DIR:-$_DEFAULT_TEST_DIR}
DATA_DIR=${BASE_DIR}/data

INPUTS_DIR=${DATA_DIR}/tests/inputs_expected
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

# TODO: Summary/covfiles have slightly hardcoded paths (relative to test directories)
$EXE --summaryFiles "${INPUTS_DIR}/tutorial/summaryfiles" --covFiles "${INPUTS_DIR}/tutorial/covfiles" --groupFile "${TUT_DIR}/group.file" \
           --SKAT --burden --MB --VT --longOutput --tabulateHits --hitsCutoff 1e-05 \
           --prefix "${RESULTS_ACTUAL_DIR}/COMBINED.QT1" --hwe 1.0e-05 --callRate 0.95

# Output files must exist, and match the expected content (skip files that contain mutable fields like dates)
expect_outputs=("COMBINED.QT1.meta.burden.results" "COMBINED.QT1.meta.MB.results" "COMBINED.QT1.meta.singlevar.results" "COMBINED.QT1.meta.SKAT_.results" "COMBINED.QT1.meta.VT_.results")
verify_results ${TUTORIAL_RESULTS_DIR} ${RESULTS_ACTUAL_DIR} ${expect_outputs[@]}


#### Print a message when all tests completed
echo "All Raremetal tests completed successfully"