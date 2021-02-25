#! /usr/bin/env bash

# Copyright 2021 Google LLC
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
# "-  Helper script to generate terraform variables        -"
# "-  file based on gcloud defaults.                       -"
# "-                                                       -"
# "---------------------------------------------------------"

# Stop immediately if something goes wrong
set -eo pipefail

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# shellcheck source=scripts/common.sh
source "$ROOT/scripts/common.sh"

# check if this is running from cloudbuild
if [[ -z "${BUILDER_OUTPUT}" ]]; then
    # gcloud config holds values related to your environment. If you already
    # defined a default project we will retrieve it and use it
    PROJECT=$(gcloud config list --format "value(core.project)")
    if [[ -z "${PROJECT}" ]]; then
        echo "gcloud cli must be configured with a default project." 1>&2
        echo "run 'gcloud config set core/project PROJECT'." 1>&2
        echo "replace 'PROJECT' with the project name." 1>&2
        exit 1;
    fi

    # Get the default zone and use it or die
    REGION=$(gcloud config list --format "value(compute.region)")
    if [[ -z "${REGION}" ]]; then
        echo "gcloud cli must be configured with a default region." 1>&2
        echo "run 'gcloud config set compute/region REGION'." 1>&2
        echo "replace 'REGION' with the zone name like us-east4." 1>&2
        exit 1;
    fi
else
    PROJECT="${PROJECT_ID}"
    REGION="${REGION}"
fi

TFVARS_FILE="$ROOT/terraform/terraform.tfvars"

if [[ -f "${TFVARS_FILE}" ]]
then
    rm "${TFVARS_FILE}"
fi
# Write out all the values we gathered into a tfvars file so you don't
# have to enter the values manually
    cat <<EOF > "${TFVARS_FILE}"
project="${PROJECT}"
region="${REGION}"
EOF