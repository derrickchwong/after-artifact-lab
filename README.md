# Overview

This lab focuses on artifacts (containers) after they have been created but not deployed to any particular environment.

## Tasks

### Step 1 - CVE Container Analysis

In this step, a docker image will be pushed to the Container Repository and will be scanned for CVEs. The goal is to practice using
policy files to either accept a CVE, or fixing the CVE so the policy no longer fails.

1. Publish two Docker containers to GCR. Images created are "good-image" and "bad-image" representing an artifact that has one (and more) CVEs and the 'good' that has no CVEs (hopefully)
    ```bash
    gcloud builds submit
    ```

1. View the Docker Digests for both Good and Bad images

    ```bash
    ./scripts/get-docker-digests.sh
    ```

1. Run the `kritis-signer` tool against the policy (/policies/container-anaylsis-policy.yaml)

    ```bash
    echo "Validating BAD image against the policy file"
    export IMAGE="$(./scripts/get-docker-digests.sh 1)"

    echo "Image Digest: ${IMAGE}"

    signer -v=10 \
        -alsologtostderr \
        -image="${IMAGE}" \
        -policy=policies/container-analysis-policy.yaml \
        -vulnz_timeout=1m \
        -mode=check-only

    if [[ $? -gt 0 ]]; then
        echo "Image vs policy did NOT pass"
    else
        echo "Image vs policy DID pass"
    fi

    ```

    > NOTE: This SHOULD fail, there are many CVEs that are not mitigated with the policy file

1. Run the `kritis-signer` tool against the policy (/policies/container-anaylsis-policy.yaml)
    ```bash
    echo "Validating GOOD image against the policy file"
    export IMAGE="$(./scripts/get-docker-digests.sh 2)"

    echo "Image Digest: ${IMAGE}"

    signer -v=10 \
        -alsologtostderr \
        -image="${IMAGE}" \
        -policy=policies/container-analysis-policy.yaml \
        -vulnz_timeout=1m \
        -mode=check-only

    if [[ $? -gt 0 ]]; then
        echo "Image vs policy did NOT pass"
    else
        echo "Image vs policy DID pass"
    fi

    ```
    > NOTE: This should NOT fail, there are a few CVEs, but they are LOW and the policy file accepts these CVEs
