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

## This script builds Kritis Signer from scratch

if [[ ! -d "$(go env GOPATH)/bin/signer" ]]; then

    git clone https://github.com/grafeas/kritis
    pushd kritis
        go get -d -v ./...
        make out/signer
        cp out/signer ../signer
        chmod +x ../signer
    popd
    sudo mv ./signer /usr/local/bin/signer
    rm -rf kritis
fi
