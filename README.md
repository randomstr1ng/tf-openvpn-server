# Deploy OpenVPN Server via Terraform on DigitalOcean
This Terraform configuration will deploy an OpenVPN Server at DigitalOcean and download the configuration into your current directory.

## Requirements
- Account at DigitalOcean
- Terraform CLI installed

You can create an Account at DigitalOcean via the following Ref-Link to support me:
https://m.do.co/c/a97df909c9cd

## Usage
Adjust the following variables as you need:
- region
- token (Your DigitalOcean access token)
- sshkeys (the IDs of your SSH Keys)

You can get the information via the API of DigitalOcean:
https://developers.digitalocean.com/documentation/v2/#introduction

Example to get the regions:
```
curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer <YOUR TOKEN HERE>" "https://api.digitalocean.com/v2/regions" 
```
How to get a token:
https://www.digitalocean.com/docs/apis-clis/api/create-personal-access-token/

Example to get the SSH Key IDs:
```
curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer <YOUR TOKEN HERE>" "https://api.digitalocean.com/v2/account/keys"
```
## Deployment & Cleanup
Initialize Terraform:
```
terraform init
```
Deploy Server
```
terraform apply -auto-approve
```
Delete Server
```
terraform destroy -auto-approve
```
