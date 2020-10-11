resource "azurerm_resource_group" "resource_group_server" {
    name     = "rg-${var.suffix}"
    location = var.region

    tags = {}
}

resource "azurerm_virtual_network" "server_network" {
    name                = "vnet-${var.suffix}"
    address_space       = ["10.0.0.0/16"]
    location            = var.region
    resource_group_name = azurerm_resource_group.resource_group_server.name

    tags = {}
}

resource "azurerm_subnet" "server_subnet" {
    name                 = "subnet-${var.suffix}"
    resource_group_name  = azurerm_resource_group.resource_group_server.name
    virtual_network_name = azurerm_virtual_network.server_network.name
    address_prefixes       = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "server_publicip" {
    name                         = "PublicIP-${var.suffix}"
    location                     = var.region
    resource_group_name          = azurerm_resource_group.resource_group_server.name
    allocation_method            = "Static"

    tags = {}
}

resource "azurerm_network_security_group" "server_nsg" {
    name                = "nsg-${var.suffix}"
    location            = var.region
    resource_group_name = azurerm_resource_group.resource_group_server.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "openVPN"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "UDP"
        source_port_range          = "*"
        destination_port_range     = "1194"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    tags = {}
}

resource "azurerm_network_interface" "vm_nic_card" {
    name                      = "nic-${var.suffix}"
    location                  = var.region
    resource_group_name       = azurerm_resource_group.resource_group_server.name

    ip_configuration {
        name                          = "var.azurerm_network_interface.vm_nic_card.name-configuration"
        subnet_id                     = azurerm_subnet.server_subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.server_publicip.id
    }

    tags = {}
}

resource "azurerm_network_interface_security_group_association" "connect_nsg_nic" {
    network_interface_id      = azurerm_network_interface.vm_nic_card.id
    network_security_group_id = azurerm_network_security_group.server_nsg.id
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "azurerm_linux_virtual_machine" "linux_server" {
    name                  = "vm-${var.suffix}"
    location              = var.region
    resource_group_name   = azurerm_resource_group.resource_group_server.name
    network_interface_ids = [azurerm_network_interface.vm_nic_card.id]
#    size                  = "Standard_DS1_v2"
    size                  = "Standard_B1s"

    os_disk {
        name              = "OSDisk-${var.suffix}"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = var.suffix
    admin_username = "${var.suffix}-admin"
    disable_password_authentication = true
        
    admin_ssh_key {
        username       = "${var.suffix}-admin"
        public_key     = tls_private_key.ssh_key.public_key_openssh
    }
    connection {
    type     = "ssh"
    user     = azurerm_linux_virtual_machine.linux_server.admin_username
    private_key = tls_private_key.ssh_key.private_key_pem
    host     = azurerm_public_ip.server_publicip.ip_address
    timeout = "4m"
    }
    provisioner "remote-exec" {
        inline = [
        "apt-get update",
        "apt-get install curl -y",
        "curl -O ${var.openvpn_install_script_location}",
        "chmod +x openvpn-install.sh",
        <<EOT
        sudo AUTO_INSTALL=y \
            APPROVE_IP=${azurerm_public_ip.server_publicip.ip_address} \
            ENDPOINT=${azurerm_public_ip.server_publicip.ip_address} \
            ./openvpn-install.sh  
        EOT
        ,
        "export MENU_OPTION='1';export CLIENT='vpnconfig';export PASS='1';./openvpn-install.sh",
        "sudo chown ${azurerm_linux_virtual_machine.linux_server.admin_username}:${azurerm_linux_virtual_machine.linux_server.admin_username} client.ovpn",
        ]
    }
    provisioner "local-exec" {
    command = "scp -i ./ssh_key.pem -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${azurerm_linux_virtual_machine.linux_server.admin_username}@${azurerm_public_ip.server_publicip.ip_address}:client.ovpn ."
    }
    tags = {}
}