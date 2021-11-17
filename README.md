# Overview

This lab focuses on artifacts (containers) after they have been created but not deployed to any particular environment.

## Tasks

### Step 1 - CVE Container Analysis

In this step, a docker image will be pushed to the Container Repository and will be scanned for CVEs. The goal is to practice using
policy files to either accept a CVE, or fixing the CVE so the policy no longer fails.

1. Add Container Analysis notes viewer to current user:
    ```bash
    gcloud projects add-iam-policy-binding ${PROJECT_ID} \
        --member=user:$(gcloud config list account --format "value(core.account)" 2> /dev/null) \
        --role=roles/containeranalysis.notes.viewer
    ```

1. Publish two Docker containers to GCR. Images created are "good-image" and "bad-image" representing an artifact that has one (and more) CVEs and the 'good' that has no CVEs (hopefully)
    ```bash
    gcloud builds submit
    ```

1. View the Docker Digests for both Good and Bad images

    ```bash
    ./scripts/get-docker-digests.sh
    ```

1. Install Signer
    ```bash
    ./script/create-kritis.sh
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


### Step 2 - DAST (ZA Proxy)

1. Build and push application to GCR

    ```bash
    gcloud builds submit
    ```

1. Set the `kubeconfig` for local `kubectl`

    ```bash
    export ZONE=us-central1-c
    gcloud container clusters get-credentials dev-cluster --zone ${ZONE} --project ${PROJECT_ID}

    kubectl cluster-info
    ```

1. Deploy container to GKE

    ```bash
    envsubst < k8s/deploy-app.yaml > deploy-final.yaml

    kubectl apply -f deploy-final.yaml
    ```

    > NOTE: This may take 3-5 minutes to start the GLBC

1. Find the IP of the Load Balancer

    ```bash
    export HOST_IP=$(kubectl get services hello-world-service --output jsonpath='{.status.loadBalancer.ingress[0].ip}')

    echo $HOST_IP
    ```

1. Look at the contents with CLI

    ```bash
    curl http://${HOST_IP}/
    ```

    > Output should look similar:

    ```text
    <html><head><title>Why, hello there! - </title></head><body><h1>Hi AppTeam!</h1><h3>Error accessing bucket ''</h3>Err: Bucket("").Objects: storage: bucket doesn't exist<br/><h2>Random Quote: I can eat glass and it doesn't hurt me.</h2><h2>Current Environment: </h2></body><html>
    ```

1. Run ZAProxy against the
    ```bash
    docker run -i owasp/zap2docker-stable zap-cli quick-scan --self-contained --start-options '-config api.disablekey=true' http://${HOST_IP}/
    ```
