#!/usr/bin/env bash

source 020-shell-script-variables.sh.inc

# Create Resource Group
echo "Creating Resource Group $TFSTATE_RESOURCE_GROUP_NAME in region $PROJECT_REGION ..."
az group create -l $PROJECT_REGION -n $TFSTATE_RESOURCE_GROUP_NAME

# Create Storage Account
echo "Creating Storage Account $STORAGE_ACCOUNT_NAME ..."
az storage account create -n $STORAGE_ACCOUNT_NAME -g $TFSTATE_RESOURCE_GROUP_NAME -l $PROJECT_REGION --sku Standard_LRS

# Create Storage Account blob
echo "Creating Storage Account blob ..."
az storage container create --name $STORAGE_CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME

# Replace placeholder backend config values in providers.tf
echo "Replacing placeholder backend config values in providers.tf ..."
sed -i "" "s/TFSTATE_RESOURCE_GROUP_NAME/$TFSTATE_RESOURCE_GROUP_NAME/" providers.tf
sed -i "" "s/STORAGE_ACCOUNT_NAME/$STORAGE_ACCOUNT_NAME/"               providers.tf
sed -i "" "s/STORAGE_CONTAINER_NAME/$STORAGE_CONTAINER_NAME/"           providers.tf
sed -i "" "s/TFSTATE_FILENAME/$TFSTATE_FILENAME/"                       providers.tf
