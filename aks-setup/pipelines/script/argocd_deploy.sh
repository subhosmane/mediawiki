#!/bin/bash
while [[ $# -gt 0 ]]; do
    key="$1"
    key2="$2"
    case $key in
        --subscription_id)
        SUBSCRIPTION_ID="$2"
        shift
        shift
        ;;
        --resource_group)
        RG_NAME="$2"
        shift
        shift
        ;;
        # --cluster_name)
        # CLUSTER_NAME="$2"
        # shift
        # shift
        # ;;
        -h|--help)
        help="true"
        shift
        ;;
        *)
        usage
        ;;
    esac
done

az aks get-credentials -f ./.kube-context --subscription $SUBSCRIPTION_ID --resource_group $RG_NAME --name $CLUSTER_NAME