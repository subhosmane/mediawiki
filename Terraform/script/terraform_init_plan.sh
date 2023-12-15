#!/bin/bash

# set -x
################# TERRAFORM INIT ###################
usage() {
    echo "USAGE: $0"
    echo "  [--working-directory] The directory which you want to perform the terraform operations on"
}

invalidParams() {
    echo "Missing required param: $1:"
    usage
    exit 1
}

terraform_init_stage() {
    echo "=================== INIT TERRAFORM ======================="
    pwd
    ls -l
    terraform version
    which terraform
    terraform init \
        -backend-config="storage_account_name=$STORAGE_ACCOUNT" \
        -backend-config="container_name=$CONTAINER_NAME" \
        -backend-config="resource_group_name=$TF_RESOURCE_GROUP" \
        -backend-config="key=$STATE_FILE_NAME" 
        
    EXIT_CODE="$?"
    if [[ "$EXIT_CODE" -gt 0 ]]; then exit "$EXIT_CODE"; fi
}
terraform_plan_stage() {
    echo "=================== PLAN TERRAFORM ======================="
    echo "workingDirectory = $workingDirectory"
    echo "$PWD"
    terraform \
        -chdir="$workingDirectory" \
        plan \
        $tf_var_files \
        -no-color \
        -var="kube_sp_app_id=$SPNID" \
        -var="kube_sp_app_secret=$SPNKey" \
        -input=false
}

while [[ $# -gt 0 ]]; do
    key="$1"
    key2="$2"
    case $key in
        --prompt_for_login)
        promt_for_login="$2"
        shift
        shift
        ;;
        --workingDirectory)
        workingDirectory="$2"
        shift
        shift
        ;;
        --tenant_id)
        tenant_id="$2"
        shift
        shift
        ;;
        --subscription_id)
        SUBSCRIPTION_ID="$2"
        shift
        shift
        ;;
        --servicePrincipalID)
        SPNID="$2"
        # echo "key=$key key2=$key2"
        shift
        shift
        ;;
        --servicePrincipalKey)
        SPNKey="$2"
        shift
        shift
        ;;
        --resource_group)
        TF_RESOURCE_GROUP="$2"
        shift
        shift
        ;;
        --storage_account)
        STORAGE_ACCOUNT="$2"
        shift
        shift
        ;;
        --container_name)
        CONTAINER_NAME="$2"
        shift
        shift
        ;;
        --state_file_name)
        STATE_FILE_NAME="$2"
        shift
        shift
        ;;
        --terraformVersion)
        terraformVersion="$2"
        shift
        shift
        ;;
        --var-files)
        var_files="$2"
        shift
        shift
        ;;
        -h|--help)
        help="true"
        shift
        ;;
        *)
        usage
        echo "key=$key key2=$key2"; exit 1
        ;;
    esac
done

## If there is no value assigned from above , then below lines either assigns a value or exits the scripts with message

[ $workingDirectory ] || workingDirectory="."

if [ -z "$SUBSCRIPTION_ID" ]; then
    invalidParams "--subscription_id"
fi
if [ -z "$TF_RESOURCE_GROUP" ]; then
    echo "rg=$resource_group and RG=$TF_RESOURCE_GROUP"
    invalidParams "--resource_group"
fi
if [ -z "$CONTAINER_NAME" ]; then
    invalidParams "--container_name"
fi
if [ -z "$STATE_FILE_NAME" ]; then
    invalidParams "--state_file_name"
fi
if [ -z "$STORAGE_ACCOUNT" ]; then
    invalidParams "--storage_account"
fi
if [ $prompt_for_login ]; then
    read -p 'TenantID: ' tenant_id
    read -p 'Service Principal ID: ' SPNID
    read -p 'Service Principal Key: ' SPNKey
    az login --service-principal -u $SPNID -p $SPNKey --tenant $tenant_id
    az account set --subscription $SUBSCRIPTION_ID
fi

echo "-------------Add var-files to tf_var_files variable -------------------"
tf_var_files='-var-file=vars.common.json'
pwd
ls -l ${BUILD_SOURCESDIRECTORY}/aks-setup/pipelines
for i in $(echo ${BUILD_SOURCESDIRECTORY}/aks-setup/pipelines/${var_files} | sed "s/,/ /g")
do
    tf_var_files="$tf_var_files -var-file=$i"
done

# az account show
ACCOUNT_KEY=$(az storage account keys list --resource-group $TF_RESOURCE_GROUP --account-name $STORAGE_ACCOUNT --query '[0].value' -o tsv)
export ARM_ACCESS_KEY=$ACCOUNT_KEY
export ARM_CLIENT_SECRET=$SPNKey
export ARM_CLIENT_ID=$SPNID
export ARM_SUBSCRIPTION_ID=$SUBSCRIPTION_ID
export ARM_TENANT_ID=$tenant_id
# env
pwd
curl https://releases.hashicorp.com/terraform/${TERRAFORMVERSION}/terraform_${TERRAFORMVERSION}_linux_amd64.zip -o terraform_${TERRAFORMVERSION}_linux_amd64.zip --silent
unzip terraform_${TERRAFORMVERSION}_linux_amd64.zip
# ./terraform version
# terraform version
mv ./terraform /usr/local/bin/terraform
# terraform version
# ls -l
terraform_init_stage
terraform_plan_stage