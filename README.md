# Deploy OpenVPN Server via Terraform on DigitalOcean
This Terraform configuration will deploy an OpenVPN Server at DigitalOcean and download the configuration into the current directory.

## Requirements
- Account at DigitalOcean
- Terraform CLI installed

You can create an Account at DigitalOcean via the following Ref-Link to support me:
https://m.do.co/c/a97df909c9cd

## Usage
Adjust the following Variables as you need:
- region
- token (Your DO access token)
- sshkeys (the IDs of your SSH Keys)

You can get the information via the API of DigitalOcean:
https://developers.digitalocean.com/documentation/v2/#introduction

Example to get the SSH Key IDs:
```
curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer <YOUR TOKEN HERE>" "https://api.digitalocean.com/v2/account/keys"
```
