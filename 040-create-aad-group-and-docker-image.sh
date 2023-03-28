#!/usr/bin/env bash

source 020-shell-script-variables.sh.inc

AKS_AAD_GROUP_NAME="$PROJECT_NAME-aks-group"
CURRENT_USER_OBJECTID=$(az ad signed-in-user show --query id -o tsv)

# Create Azure AD Group for AKS admins
echo "Creating Azure AD Group for AKS admins $AKS_AAD_GROUP_NAME ..."
az ad group create --display-name $AKS_AAD_GROUP_NAME --mail-nickname $AKS_AAD_GROUP_NAME
AKS_AAD_GROUP_ID=$(az ad group show --group "$AKS_AAD_GROUP_NAME" --query id -o tsv)

# Add Current az login user to Azure AD Group
echo "Adding current az login user $CURRENT_USER_OBJECTID to the Azure AD Group ..."
az ad group member add --group $AKS_AAD_GROUP_NAME --member-id $CURRENT_USER_OBJECTID

# Build Docker image to push to the ACR later
echo "Building Docker image that will be pushed to the ACR ..."
docker build --platform=linux/amd64 -t uberapp Docker

# Replace placeholder values in misc files
echo "Replacing placeholder values in base.auto.tfvars ..."
sed -i "" "s/PROJECT_NAME/$PROJECT_NAME/"         base.auto.tfvars
sed -i "" "s/PROJECT_REGION/$PROJECT_REGION/"     base.auto.tfvars
sed -i "" "s/AKS_AAD_GROUP_ID/$AKS_AAD_GROUP_ID/" base.auto.tfvars
echo "Replacing placeholder values in deployment.yml ..."
sed -i "" "s/PROJECT_NAME/$PROJECT_NAME/"         deployment.yml
