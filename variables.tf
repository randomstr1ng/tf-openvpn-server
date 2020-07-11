variable "token" {}
variable "hostname" {
    default = "vpn-server"
}
variable "region" {
    default = "fra1"
}
variable "sshkeys" {}
variable "private_key" {
    default = "~/.ssh/id_rsa"
}
variable "openvpn_install_script_location" {
  default     = "https://raw.githubusercontent.com/randomstr1ng/openvpn-server-installer/master/openvpn-install.sh"
}
variable "username" {
    default = "root"
}