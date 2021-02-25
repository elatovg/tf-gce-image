#! /usr/bin/env bash

# Copyright 20201 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Creates sample gce image and gce                     -"
# "-                                                       -"
# "---------------------------------------------------------"
set -o errexit
set -o pipefail

if [[ -z "$1" ]]; then
    MODE="local"
else
    MODE="remote"
fi

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
# shellcheck source=scripts/common.sh
source "$ROOT/scripts/common.sh"

# Generate the variables to be used by Terraform
# shellcheck source=scripts/generate-tf.sh
"$ROOT/scripts/generate-tf.sh"

if [[ "${MODE}" == "remote" ]]; then
    BACKEND_TF_FILE="$ROOT/terraform/be.tf"
    if [[ -f "${BACKEND_TF_FILE}" ]]; then
        rm "${BACKEND_TF_FILE}"
    fi
    echo 'terraform { backend "gcs" { prefix  = "state" } }' >  "${BACKEND_TF_FILE}"
fi

# Get the Project Information
#PROJECT=$(gcloud config list --format "value(core.project)")
#ZONE=$(gcloud config list --format "value(compute.zone)")

# Enable any APIs we need
gcloud services enable compute.googleapis.com 

# Initialize and run Terraform
if [[ ! -z "${BUILDER_OUTPUT}" ]]; then
    PROJECT_ID=$(gcloud config list --format "value(core.project)")
    BUCKET="terraform-st"
    (cd "$ROOT/terraform"; terraform init -input=false -backend-config="project=${PROJECT_ID}" \
    -backend-config="bucket=${BUCKET}")
    (cd "$ROOT/terraform"; terraform apply -input=false -auto-approve)
else
    if [[ "${MODE}" == "remote" ]]; then
        (cd "$ROOT/terraform"; terraform init -input=false -backend-config="project=${PROJECT_ID}" \
        -backend-config="bucket=${BUCKET}")
        (cd "$ROOT/terraform"; terraform apply -input=false -auto-approve)
    else
        (cd "$ROOT/terraform"; terraform init -input=false)
        (cd "$ROOT/terraform"; terraform apply -input=false -auto-approve)
    fi
fi