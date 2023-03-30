#!/usr/bin/env bash
source setup.inc.sh

# Check requirements
NOTFOUND=false
for i in $REQUIREMENTS; do
  which $i > /dev/null && echo "$i found" || { echo "$i not found in PATH"; NOTFOUND=true; }
done
if [[ "$NOTFOUND" == "true" ]]; then
  echo "Please install and/or add unmet requirements to the PATH variable and try again"
  exit 1
else
  echo "All requirements met"
fi

# If not running via GH Actions and secrets file is not present, then create a
# Service Principal for CI/CD and store relevant secrets in a Git-ignored file
echo "Checking if script is run by GitHub Actions"
if [[ "$GITHUB_ACTIONS" == "true" ]]; then
  echo "Run by GitHub Actions, skipping creation of Service Principal"
else
  echo "Not run by GitHub Actions"
  echo "Checking if previous CI/CD secrets file exists"
  if [[ -f "$CI_CD_SECRETS_FILE" ]]; then
    echo "Found file "$CI_CD_SECRETS_FILE", skipping creation of Service Principal"
  else
    echo "No previous CI/CD secrets file found, proceeding"
    echo "Retrieving Subscription ID"
    AZ_SUB=$(az account show --query id --output tsv)
    echo "Creating Service Principal for CI/CD"
    AZ_AD_SP_OUTPUT=$(az ad sp create-for-rbac \
      --name "$PROJECT_NAME" \
      --role contributor \
      --scopes /subscriptions/$AZ_SUB \
      --sdk-auth \
    )
    if [[ $? -eq 0 ]]; then
      echo "Service Principal for CI/CD created successfully"
      echo "Saving Service Principal authentication JSON"
      echo "$AZ_AD_SP_OUTPUT" > $CI_CD_SECRETS_FILE
      echo "Service Principal authentication JSON saved as $CI_CD_SECRETS_FILE"
      echo "You may copy the contents into a secret in your CI solution"
    else
      echo "Error creating Service Principal for CI/CD"
      exit 2
    fi
  fi
fi

# Create Resource Group
echo "Creating Resource Group $TFSTATE_RESOURCE_GROUP_NAME in region $PROJECT_REGION"
az group create -l $PROJECT_REGION -n $TFSTATE_RESOURCE_GROUP_NAME
if [[ $? -eq 0 ]]; then
  echo "Resource Group created successfully"
else
  echo "Error creating Resource Group"
  exit 3
fi

# Create Storage Account
echo "Creating Storage Account $STORAGE_ACCOUNT_NAME"
az storage account create -n $STORAGE_ACCOUNT_NAME -g $TFSTATE_RESOURCE_GROUP_NAME -l $PROJECT_REGION --sku Standard_LRS
if [[ $? -eq 0 ]]; then
  echo "Storage Account created successfully"
else
  echo "Error creating Storage Account"
  exit 4
fi

# Create Storage Container
echo "Creating Storage Container $STORAGE_CONTAINER_NAME"
az storage container create --name $STORAGE_CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME
if [[ $? -eq 0 ]]; then
  echo "Storage Container created successfully"
else
  echo "Error creating Storage Container"
  exit 5
fi

# Replace placeholder backend config values in providers.tf
# The FreeBSD version of sed needs a blank string passed as a value to the -i argument
if [[ "$OSTYPE" == "darwin"* ]] || [[ "$OSTYPE" == "freebsd"* ]]; then
  SED_BSD="\"\""
fi
echo "Replacing placeholder backend config values in providers.tf"
sed -i $SED_BSD "s/TFSTATE_RESOURCE_GROUP_NAME/$TFSTATE_RESOURCE_GROUP_NAME/" providers.tf
sed -i $SED_BSD "s/STORAGE_ACCOUNT_NAME/$STORAGE_ACCOUNT_NAME/" providers.tf
sed -i $SED_BSD "s/STORAGE_CONTAINER_NAME/$STORAGE_CONTAINER_NAME/" providers.tf
sed -i $SED_BSD "s/TFSTATE_FILENAME/$TFSTATE_FILENAME/" providers.tf
