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

## NOTE: ORDER MATTERS (for the workshop, using "bad" as first, "good" as second)
IMAGES=( "gcr.io/${PROJECT_ID}/bad-image:latest" "gcr.io/${PROJECT_ID}/good-image:latest" )

IMAGES_DIGESTS=()
INDEX=""

if [[ ! -z "$1" ]]; then
    INDEX=$(($1 - 1))
fi

if [[ -z "${INDEX}" ]]; then
    echo "Getting Digests..."
fi

for img in "${IMAGES[@]}"; do
    docker pull ${img} > /dev/null 2>&1
    digest="$(docker image inspect ${img} --format '{{index .RepoDigests 0}}')"
    IMAGES_DIGESTS+=("${digest}")
done

if [[ ! -z "${INDEX}" ]]; then
    echo "${IMAGES_DIGESTS[${INDEX}]}"
else
    echo -e "\nAll Digests\n"
    for digest in "${IMAGES_DIGESTS[@]}"; do
        echo ${digest}
    done

fi
