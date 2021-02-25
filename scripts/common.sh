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
# "-  Common commands for all scripts                      -"
# "-                                                       -"
# "---------------------------------------------------------"

# gcloud are required
command -v gcloud >/dev/null 2>&1 || { \
 echo >&2 "gcloud is required but it's not installed.  Aborting."; exit 1; }


function check_command_status() {
    local -r command=$1
    local -r component=$2
    if ! ${command} > /dev/null; then
        echo "FAIL: ${component} does not exist"
        exit 1
    else
        echo "${component} exists"
    fi
}
