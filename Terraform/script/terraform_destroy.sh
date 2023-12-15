#!/bin/bash

#set -x
############################ DESTORY ########################################
terraform_destroy() { 
    echo "======================================================="
    echo "================ Destroy Terraform ======================="
    echo "======================================================="

    terraform \
        -chdir="$workingDirectory" \
        destroy \
        $tf_var_files \
        -no-color \
        -var="kube_sp_app_id=$SPNID" \
        -var="kube_sp_app_secret=$SPNKey" \
        -input=false \
        -auto-approve 
    # EXIT_CODE="$?"
    # if [[ "$EXIT_CODE" -gt 0 ]]; then exit "$EXIT_CODE"; fi
}

###################### MAIN #############################################
# This path won't work if not using BASH
. "${BASH_SOURCE%/*}"/terraform_init_plan.sh
terraform_destroy