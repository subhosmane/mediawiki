#!/bin/bash
export STORAGE_ACCOUNT=tf_sa
export CONTAINER_NAME=tfstore
export TF_RESOURCE_GROUP=TF_RESOURCE_GROUP

if [ -z "$STORAGE_ACCOUNT" ]; then
    echo "Add value for STORAGE_ACCOUNT"
    exit 1
fi

if [ -z "$CONTAINER_NAME" ]; then
    echo "Add value for CONTAINER_NAME"
    exit 1
fi

if [ -z "$TF_RESOURCE_GROUP" ]; then
    echo "Add value for TF_RESOURCE_GROUP"
    exit 1
fi

az storage account create --name $STORAGE_ACCOUNT -g $TF_RESOURCE_GROUP -o table
containerExists=$(az storage container exists --account-name "$STORAGE_ACCOUNT" --name "$CONTAINER_NAME" --query exists --output tsv)
echo $containerExists
if [[ $containerExists != "true" ]]
then
    echo "Creating container: $CONTAINER_NAME"
    container_result=$(az storage container create --name "$CONTAINER_NAME" --account-name "$STORAGE_ACCOUNT" --auth-mode login --query created --output tsv)
    if [[ $container_result ]]
    then
        echo "Container Created Sucessfully"
    else
        echo "Error - Unable to create storage container"
        exit 1
    fi

    permissionResult=$(az storage container set-permission --name "$CONTAINER_NAME" --account-name "$STORAGE_ACCOUNT" --public-access off)
    if [[ $permissionResult ]]
    then
        echo "Container Permission set successfully"
    else
        echo "Error - unable to set permission on storage account"
        exit 1
    fi
fi
