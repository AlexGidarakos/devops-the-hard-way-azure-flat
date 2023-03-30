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
  echo "All requirements met, proceeding..."
fi

# If not running via GH Actions and secrets file is not present, then create a
# Service Principal for CI/CD and store relevant secrets in a Git-ignored file
[[ "$GITHUB_ACTIONS" != "true" ]] && [ ! -f "$CI_CD_SECRETS_FILE" ] && {
  echo "Creating Service Principal for CI/CD";
  AZ_SUB=$(az account show --query id --output tsv);
  AZ_AD_SP_OUTPUT=$(az ad sp create-for-rbac \
    --name "$PROJECT_NAME" \
    --role contributor \
    --scopes /subscriptions/$AZ_SUB \
    --sdk-auth \
    ) && {
    echo "$AZ_AD_SP_OUTPUT" > $CI_CD_SECRETS_FILE && \
    echo "Service Principal authentication JSON saved as $CI_CD_SECRETS_FILE" \
    ;
  }
}
