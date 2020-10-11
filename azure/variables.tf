# Provider Variables
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
# Main Variables
variable "suffix" {}
variable "region" {}

variable "openvpn_install_script_location" {
  default     = "https://raw.githubusercontent.com/randomstr1ng/openvpn-server-installer/master/openvpn-install.sh"
}