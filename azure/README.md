# Deploy OpenVPN Server via Terraform on Microsoft Azure
This Terraform configuration will deploy an OpenVPN Server at Azure and download the configuration into your current directory.

## Requirements
- Account at Microsoft Azure
- Terraform CLI installed

## Usage
Adjust the following variables as you need:
- region
- suffix
- Azure access tokens:
    - subscription_id
    - client_id
    - client_secret
    - tenant_id

How to get a access tokens:
- Execute the following command via azure cli:
```
az ad sp create-for-rbac -n "<DESCRIPTION NAME>" --role="Contributor" --scope="/subscriptions/<TENANT ID>"
```

## Deployment & Cleanup
- Deploy Server
```bash
terraform init
terraform apply -var-file variables.tfvars -auto-approve
```

- Delete Server
```bash
terraform destroy -var-file variables.tfvars -auto-approve
```