#!/bin/bash

set -e

# AZURE_AD_B2B_CLIENT_ID -- service principal ID to be used for login and further command execution
# AZURE_AD_B2B_CLIENT_SECRET -- password for above service principal
# AZURE_AD_B2B_TENANT_ID -- tennant ID of home Azure Actice Directory where above identity is maintained
# AZURE_SUBSCRIPTION_ID -- Subscription within above Azure Active Directory in which to operate

# AZURE_STORAGE_ACCOUNT_NAME_TERRAFORM -- name of the storage account in which to maintain the terraform state
# AZURE_RESOURCE_GROUP -- resource group where the storage account for central state maintenanec is situated
# TFSTATE_CONTAINER -- Container (folder, directory) within above mentioned storage account
# TFSTATE_FILE_NAME -- filename under which to preserve the terraform state

export TFSTATE_FILE_NAME = eventhub-terraform-bug.tfstate

# AZ CLI service principal login
az login --service-principal --username "${AZURE_AD_B2B_CLIENT_ID}" --tenant "${AZURE_AD_B2B_TENANT_ID}" --password "${AZURE_AD_B2B_CLIENT_SECRET}"
az account set --subscription "${AZURE_SUBSCRIPTION_ID}"

export ARM_CLIENT_ID="${AZURE_AD_B2B_CLIENT_ID}"
export ARM_SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID}"
export ARM_TENANT_ID="${AZURE_AD_B2B_TENANT_ID}"
export ARM_CLIENT_SECRET="${AZURE_AD_B2B_CLIENT_SECRET}"

# Terraform Remote state initialization
export BACKEND_TFVARS=backend.tfvars
STORAGE_KEY=$(az storage account keys list --account-name $AZURE_STORAGE_ACCOUNT_NAME_TERRAFORM --resource-group $AZURE_RESOURCE_GROUP -o tsv --query '[1].value' )

echo "storage_account_name = \"${AZURE_STORAGE_ACCOUNT_NAME_TERRAFORM}\"" > $BACKEND_TFVARS
echo "container_name       = \"${TFSTATE_CONTAINER}\"" >> $BACKEND_TFVARS
echo "resource_group_name  = \"${AZURE_RESOURCE_GROUP}\"" >> $BACKEND_TFVARS
echo "key                  = \"${TFSTATE_FILE_NAME}\"" >> $BACKEND_TFVARS
echo "access_key           = \"${STORAGE_KEY}\"" >> $BACKEND_TFVARS

terraform init -backend-config=$BACKEND_TFVARS
terraform plan -out=enrichment.tfplan
terraform apply -input=false enrichment.tfplan
