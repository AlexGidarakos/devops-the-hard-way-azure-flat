REQUIREMENTS="az terraform docker kubelogin kubectl"
PROJECT_BASENAME="devopshard"
PROJECT_PREFIX="myname"

# Check if running within a GitHub Actions runner
# Based on https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables
# If true, prepend a "gh" string to the project prefix
[[ "$GITHUB_ACTIONS" == "true" ]] && PROJECT_PREFIX="gh${PROJECT_PREFIX}"

PROJECT_REGION="uksouth"
STORAGE_CONTAINER_NAME="tfstate"
TFSTATE_FILENAME="terraform.tfstate"
PROJECT_NAME="${PROJECT_PREFIX}${PROJECT_BASENAME}"
CI_CD_SECRETS_FILE="cicd-secrets-gitignore.json"
AKS_AAD_GROUP_NAME="$PROJECT_NAME-aks-group"
TFSTATE_RESOURCE_GROUP_NAME="$PROJECT_NAME-tfstate-rg"
# Following var value MUST be max 24 chars and include only lowercase letters and numbers
STORAGE_ACCOUNT_NAME="${PROJECT_NAME}tf"
RESOURCE_GROUP_NAME="$PROJECT_NAME-rg"
