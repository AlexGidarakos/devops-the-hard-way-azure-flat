#!/usr/bin/env bash

source 020-shell-script-variables.sh.inc

# Create Resource Group
echo "Creating Resource Group $RESOURCE_GROUP_NAME in region $PROJECT_REGION ..."
az group create -l $PROJECT_REGION -n $RESOURCE_GROUP_NAME

# Create Storage Account
echo "Creating Storage Account $STORAGE_ACCOUNT_NAME ..."
az storage account create -n $STORAGE_ACCOUNT_NAME -g $RESOURCE_GROUP_NAME -l $PROJECT_REGION --sku Standard_LRS

# Create Storage Account blob
echo "Creating Storage Account blob ..."
az storage container create  --name tfstate --account-name $STORAGE_ACCOUNT_NAME
