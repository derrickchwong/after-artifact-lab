#!/bin/bash

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

## This script provisions the infrastructure for this workshop

if [[ -z "${PROJECT_ID}" ]]; then
    echo "PROJECT_ID is not defined and needs to be."
    exit 1
fi

gcloud config set project ${PROJECT_ID}

export PROJECT_NUMBER=$(gcloud projects list --filter="${PROJECT_ID}" --format="value(PROJECT_NUMBER)")

## Enable Services
gcloud services enable \
  cloudbuild.googleapis.com \
  containerregistry.googleapis.com \
  containerscanning.googleapis.com

## Create GKE instance (used for deployment of container)


## Create Kritis signer tool

./create-kritis.sh

export IMAGE="gcr.io/cloud-marketplace/google/debian10@sha256:0642278af4db752391dfee6e91fbad1ebfca746d5ad2770706da737c5245edb9"

signer -v=10 \
      -alsologtostderr \
      -image="${IMAGE}" \
      -policy=policies/container-analysis-policy.yaml \
      -vulnz_timeout=1m \
      -mode=check-only
