#!/bin/bash

## This script builds Kritis Signer from scratch

if [[ ! -d "$(go env GOPATH)/bin/signer" ]]; then

    git clone https://github.com/grafeas/kritis
    pushd kritis
        go get -d -v ./...
        make out/signer
        cp out/signer ../signer
        chmod +x ../signer
    popd
    mv ./signer $(go env GOPATH)/bin/signer
    rm -rf kritis
fi

signer --help