# output "tls_private_key" {
#     value = tls_private_key.ssh_key.private_key_pem
# }

resource "local_file" "ssh_key" {
    content = tls_private_key.ssh_key.private_key_pem
    filename = "${path.module}/ssh_key.pem"
    file_permission = "0600"
}

output "public_ip" {
    value = azurerm_public_ip.server_publicip.ip_address
}

output "username" {
    value = azurerm_linux_virtual_machine.linux_server.admin_username
}