PROJECT_BASENAME="devopshard"
PROJECT_PREFIX="alexg"
PROJECT_NAME="${PROJECT_PREFIX}${PROJECT_BASENAME}"
RESOURCE_GROUP_NAME="$PROJECT_NAME-tfstate-rg"
PROJECT_REGION="uksouth"

# Following var value MUST be max 24 chars and include only lowercase letters and numbers
STORAGE_ACCOUNT_NAME="${PROJECT_NAME}tfstate"
