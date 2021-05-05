variable "token" {}
variable "hostname" {
    default = "vpn-server"
}
variable "region" {
    default = "fra1"
}
variable "openvpn_install_script_location" {
  default     = "https://raw.githubusercontent.com/randomstr1ng/openvpn-server-installer/master/openvpn-install.sh"
}
variable "username" {
    default = "root"
}
variable "vm_image" {
    default = "ubuntu-20-04-x64"
}
variable "vm_size" {
    default = "s-1vcpu-1gb"
}
variable "ssh_private_key" {
    default = "ssh_key.pem"
}