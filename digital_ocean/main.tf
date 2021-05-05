resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "digitalocean_ssh_key" "default" {
  name       = "tf-ssh-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "digitalocean_droplet" "server" {
	image = var.vm_image
  name = var.hostname
	region = var.region
	size = var.vm_size
	ssh_keys = [digitalocean_ssh_key.default.fingerprint]
  connection {
  type     = "ssh"
  user     = "root"
  private_key = file(var.ssh_private_key)
  host     = self.ipv4_address
  timeout = "2m"
  }
  provisioner "remote-exec" {
  inline = [
    "apt-get update",
    "apt-get install curl -y",
    "curl -O ${var.openvpn_install_script_location}",
    "chmod +x openvpn-install.sh",
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
    command = "scp -i ${var.ssh_private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.username}@${digitalocean_droplet.server.ipv4_address}:vpnconfig.ovpn ."
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
