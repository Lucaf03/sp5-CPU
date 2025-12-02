#!/bin/bash
echo "Running setup.sh..."

export SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
export SIM_PATH=$(dirname "$SCRIPT_PATH")
export BUILD_PATH=${SIM_PATH}/build
export PROJECT_PATH=$(dirname "$SIM_PATH")
export RTL_PATH=${PROJECT_PATH}/RTL

echo "Exiting setup.sh..."