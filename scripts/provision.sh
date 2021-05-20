#!/bin/bash

## This script provisions the infrastructure for this workshop

if [[ -z "${PROJECT_ID}" ]]; then
    echo "PROJECT_ID is not defined and needs to be."
    exit 1
fi

