#!/usr/bin/env bash

source setup.inc

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

# Create Service Principal for CI/CD and store relevant secrets in Git-ignored file
AZ_AD_SP_OUTPUT=$(az ad sp create-for-rbac --name $PROJECT_NAME)
AZURE_AD_CLIENT_ID=$(echo "$AZ_AD_SP_OUTPUT" | grep appId | cut -d\" -f4)
AZURE_AD_CLIENT_SECRET=$(echo "$AZ_AD_SP_OUTPUT" | grep password | cut -d\" -f4)
AZURE_AD_TENANT_ID=$(echo "$AZ_AD_SP_OUTPUT" | grep tenant | cut -d\" -f4)
AZURE_SUBSCRIPTION_ID=$(az account show --query id --output tsv)
echo -e \
  "AZURE_AD_CLIENT_ID=$AZURE_AD_CLIENT_ID" \
  "\nAZURE_AD_CLIENT_SECRET=$AZURE_AD_CLIENT_SECRET" \
  "\nAZURE_AD_TENANT_ID=$AZURE_AD_TENANT_ID" \
  "\nAZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID" \
  > cicdsecrets-gitignore.txt
