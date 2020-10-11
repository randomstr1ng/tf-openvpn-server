resource "digitalocean_droplet" "server" {
	image = "ubuntu-20-04-x64"
  name = "${var.hostname}"
	region = "${var.region}"
	size = "s-1vcpu-1gb"
	ssh_keys = var.sshkeys
    connection {
    type     = "ssh"
    user     = "root"
    private_key = file(var.private_key)
    host     = self.ipv4_address
    timeout = "2m"
    }
    provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get install curl -y",
      "curl -O ${var.openvpn_install_script_location}",
      "chmod +x openvpn-install.sh",
      # Revert to Original version
    <<EOT
      sudo AUTO_INSTALL=y \
           APPROVE_IP=${digitalocean_droplet.server.ipv4_address} \
           ENDPOINT=${digitalocean_droplet.server.ipv4_address} \
           ./openvpn-install.sh  
    EOT
      ,
      "export MENU_OPTION='1';export CLIENT='vpnconfig';export PASS='1';./openvpn-install.sh",
    ]
  }
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.username}@${digitalocean_droplet.server.ipv4_address}:vpnconfig.ovpn ."
  }
}

resource "digitalocean_firewall" "openvpn" {
  name = "openvpn-server-fw"

  droplet_ids = [digitalocean_droplet.server.id]
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "udp"
    port_range       = "1194"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
      protocol = "tcp"
      port_range = "all"
      destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
      protocol = "udp"
      port_range = "all"
      destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
      protocol = "icmp"
      destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
