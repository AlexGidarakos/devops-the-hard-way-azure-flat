REQUIREMENTS="az terraform docker kubelogin kubectl"
PROJECT_BASENAME="devopshard"
PROJECT_PREFIX="yourname"

# Check if running within a GitHub Actions runner
# Based on https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables
# If true, set project prefix to gha
[[ "$GITHUB_ACTIONS" == "true" ]] && PROJECT_PREFIX="gha"

PROJECT_REGION="uksouth"
STORAGE_CONTAINER_NAME="tfstate"
TFSTATE_FILENAME="terraform.tfstate"
PROJECT_NAME="${PROJECT_PREFIX}${PROJECT_BASENAME}"
AKS_AAD_GROUP_NAME="$PROJECT_NAME-aks-group"
TFSTATE_RESOURCE_GROUP_NAME="$PROJECT_NAME-tfstate-rg"
# Following var value MUST be max 24 chars and include only lowercase letters and numbers
STORAGE_ACCOUNT_NAME="${PROJECT_NAME}tf"
RESOURCE_GROUP_NAME="$PROJECT_NAME-rg"
