#!/usr/bin/env bash
source setup.inc.sh
NOTFOUND=0

for i in $REQUIREMENTS; do
  which $i > /dev/null && echo "$i found" || { echo "$i not found in PATH"; NOTFOUND=1; }
done

((NOTFOUND)) && { echo "Please install and/or add unmet requirements to the PATH variable and try again"; exit $NOTFOUND; }

# If not running via GH Actions and secrets file is not present, then create a
# Service Principal for CI/CD and store relevant secrets in a Git-ignored file
[[ "$GITHUB_ACTIONS" != "true" ]] && [ ! -f "$CI_CD_SECRETS_FILE" ] && {
  echo "Creating Service Principal for CI/CD";
  AZ_AD_SP_OUTPUT=$(az ad sp create-for-rbac \
    --name "$PROJECT_NAME"\
    --sdk-auth \
    ) && {
    echo "$AZ_AD_SP_OUTPUT" > $CI_CD_SECRETS_FILE && \
    echo "Service Principal authentication JSON saved as $CI_CD_SECRETS_FILE" \
    ;
  }
}
