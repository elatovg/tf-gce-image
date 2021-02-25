#! /usr/bin/env bash

# Copyright 2019 Google LLC
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
# "-  Validation script checks if resources are deployed   -"
# "-                                                       -"
# "---------------------------------------------------------"

# Do not set exit on error, since the rollout status command may fail
set -o nounset
set -o pipefail

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
# shellcheck source=scripts/common.sh
source "$ROOT/scripts/common.sh"


cd "$ROOT/terraform" || exit; \
    GCE_NAME=$(terraform output gce_name) \
    GCE_ZONE=$(terraform output gce_zone) \
    TEMPLATE_NAME=$(terraform output instance_template) \
    MIG_NAME=$(terraform output mig) \
#    HC_FW_NAME=$(terraform output hc_fw_rule) \
#    HTTP_FW_NAME=$(terraform output mig_fw_rule) \
    HC_NAME=$(terraform output hc_http) \
    BES_NAME=$(terraform output ilb_be) \
    IB_FRW_NAME=$(terraform output ilb_forward_rule)


REGION=${GCE_ZONE%-*}

check_command_status "gcloud compute instances describe ${GCE_NAME} --zone ${GCE_ZONE}" "GCE Instance"
check_command_status "gcloud compute instance-templates describe ${TEMPLATE_NAME}" "Instance Template"
check_command_status "gcloud compute instance-groups describe ${MIG_NAME} --zone ${GCE_ZONE}" "MIG"
#check_command_status "gcloud compute firewall-rules describe ${HC_FW_NAME}" "HC Firewall Rule"
#check_command_status "gcloud compute firewall-rules describe ${HTTP_FW_NAME}" "HTTP Firewall Rule"
check_command_status "gcloud compute health-checks describe ${HC_NAME}" "HTTP Health Check"
check_command_status "gcloud compute backend-services describe ${BES_NAME} --region ${REGION}" "ILB Backend Service"
check_command_status "gcloud compute forwarding-rules describe ${IB_FRW_NAME} --region ${REGION}" "Forwarding Rule"

echo "Deployment is finished."