#!/bin/bash

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

echo "Veuillez créer votre jeton super admin en utilisant l'UI Scaleway."
echo "Please create your scaleway super admin token"
read -r -p "Done"

echo "Please create an API key"
read -r -p "Enter your access key (ACCESS_KEY) : " scw_access_key
read -r -p "Enter your secret key (SECRET_KEY) : " scw_secret_key
read -r -p "Enter your organization id (SCW_ORGANIZATION_ID) : " scw_organization_id

tfvars_filename="tmp.auto.tfvars"

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

terraform init
terraform apply -auto-approve -var-file="$tfvars_filename"

rm "$tfvars_filename"

if [ -f "$backend_backup_filename" ]; then
    mv $backend_backup_filename $backend_filename
    echo "$backend_filename has been restored"
else
    echo "$backend_backup_filename does not exist, please restore it manually"
    exit 1
fi

terraform init -migrate-state

echo "Bootstrapping done!"
