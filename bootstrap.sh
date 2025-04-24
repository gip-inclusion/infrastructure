#!/bin/bash
set -eu

echo "
============== WARNING ==============
  This script is highly destructive
Run it wisely after reading README.md
====================================="

if ! command -v terraform &> /dev/null; then
    echo "Terraform is not installed, please refer to https://developer.hashicorp.com/terraform/install"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo "You are not authenticated to gh cli"
    exit 1
fi

echo "Create your superadmin API key"
read -s -r -p "Enter your access key (ACCESS_KEY): " scw_access_key
echo
read -s -r -p "Enter your secret key (SECRET_KEY): " scw_secret_key
echo
read -s -r -p "Enter your organization id (SCW_ORGANIZATION_ID): " scw_organization_id
echo

tfvars_filename=$(mktemp)

cat > "$tfvars_filename" <<EOF
scw_access_key = "$scw_access_key"
scw_secret_key = "$scw_secret_key"
scw_organization_id = "$scw_organization_id"
EOF

backend_filename="backend.tf"
backend_backup_filename="$backend_filename.backup"

if [ -f "$backend_filename" ]; then
    mv $backend_filename $backend_backup_filename
    echo "$backend_filename has been renamed to $backend_backup_filename"
else
    echo "$backend_filename does not exist, please refer to the origin codebase"
    exit 1
fi

terraform init -backend-config="$tfvars_filename"
terraform apply -auto-approve -var-file="$tfvars_filename"

# access_key and secret_key are used by the terraform backend to access the
# state, scw_* are used by terraform.
cat > "$tfvars_filename" <<EOF
access_key = $(terraform output ci_access_key)
secret_key = $(terraform output ci_secret_key)
EOF

if [ -f "$backend_backup_filename" ]; then
    mv $backend_backup_filename $backend_filename
    echo "$backend_filename has been restored"
else
    echo "$backend_backup_filename does not exist, please restore it manually"
    exit 1
fi

terraform init -backend-config="$tfvars_filename" -migrate-state

shred -u "$tfvars_filename"

REPOSITORY=gip-inclusion/infrastructure

gh secret set "SCW_ORGANIZATION_ID" --body "${scw_organization_id}" --app actions --repo $REPOSITORY
gh secret set "SCW_TF_CI_ACCESS_KEY" --body "$(terraform output ci_access_key)" --app actions --repo $REPOSITORY
gh secret set "SCW_TF_CI_SECRET_KEY" --body "$(terraform output ci_secret_key)" --app actions --repo $REPOSITORY

echo "Bootstrapping done!"
