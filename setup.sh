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
    else
      echo "Error creating Service Principal for CI/CD"
      exit 2
    fi
  fi
fi
