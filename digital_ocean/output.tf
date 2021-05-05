output "public_ip" {
	# Output the Public IP of Droplet
	value = digitalocean_droplet.server.ipv4_address
}
resource "local_file" "ssh_key" {
    content = tls_private_key.ssh_key.private_key_pem
    filename = "${path.module}/ssh_key.pem"
    file_permission = "0600"
}