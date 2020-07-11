output "public_ip" {
	# Output the Public IP of Droplet
	value = digitalocean_droplet.server.ipv4_address
}