#!/bin/bash
set -e

# service principal ID to be used for login and further command execution
export AZURE_AD_B2B_CLIENT_ID=""

# password for above service principal
export AZURE_AD_B2B_CLIENT_SECRET=""

# tennant ID of home Azure Actice Directory where above identity is maintained
export AZURE_AD_B2B_TENANT_ID=""

# Subscription within above Azure Active Directory in which to operate
export AZURE_SUBSCRIPTION_ID=""

# name of the storage account in which to maintain the terraform state
export AZURE_STORAGE_ACCOUNT_NAME_TERRAFORM=""

# password for accesing the above mentioned storage account where the terraform state is/will be maintained
export AZURE_STORAGE_ACCOUNT_KEY_TERRAFORM=""

# resource group where the storage account for central state maintenance is situated
export AZURE_RESOURCE_GROUP=""

# Container (folder, directory) within above mentioned storage account
export TFSTATE_CONTAINER="terraform-tfstate"

# Filename under which to preserve the terraform state
export TFSTATE_FILE_NAME="eventhub-terraform-bug.tfstate"