#!/usr/bin/env bash

source 010-shell-script-variables.sh.inc

AZURE_AD_GROUP_NAME="$PROJECT_NAME-aks-group"
CURRENT_USER_OBJECTID=$(az ad signed-in-user show --query id -o tsv)

# Create Azure AD Group
echo "Creating Azure AD Group $AZURE_AD_GROUP_NAME ..."
az ad group create --display-name $AZURE_AD_GROUP_NAME --mail-nickname $AZURE_AD_GROUP_NAME
AZURE_GROUP_ID=$(az ad group show --group "$AZURE_AD_GROUP_NAME" --query id -o tsv)
echo "Azure AD Group is: $AZURE_GROUP_ID"
echo "AZURE_GROUP_ID=$AZURE_GROUP_ID" > 040-AZURE-AD-GROUP-ID-gitignore.txt

# Add Current az login user to Azure AD Group
echo "Adding current az login user $CURRENT_USER_OBJECTID to the Azure AD Group ..."
az ad group member add --group $AZURE_AD_GROUP_NAME --member-id $CURRENT_USER_OBJECTID
