#!/bin/bash

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

