#!/usr/bin/env bash
source setup.inc.sh
NOTFOUND=0

for i in $REQUIREMENTS; do
  which $i > /dev/null && echo "$i found" || { echo "$i not found in PATH"; NOTFOUND=1; }
done

((NOTFOUND)) && { echo -e "Please install and/or add unmet requirements to the PATH variable and try again"; exit $NOTFOUND; }

# Create Resource Group for Storage account to be used for the remote Terraform state
echo "Creating Resource Group $TFSTATE_RESOURCE_GROUP_NAME in region $PROJECT_REGION ..."
az group create -l $PROJECT_REGION -n $TFSTATE_RESOURCE_GROUP_NAME

# Create the Storage Account
echo "Creating Storage Account $STORAGE_ACCOUNT_NAME ..."
az storage account create -n $STORAGE_ACCOUNT_NAME -g $TFSTATE_RESOURCE_GROUP_NAME -l $PROJECT_REGION --sku Standard_LRS

# Create a blob within the Storage Account
echo "Creating Storage Account blob ..."
az storage container create --name $STORAGE_CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME
