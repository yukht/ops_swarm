variable "my_network" {
  # Variable settings see in credentials.auto.tfvars
  description = "network settings"
  type        = map(string)
}

module "network_ansible" {
  source                 = "./modules/network"
  network_description    = "Создание подсети для клиентов ansible"
  network_name           = "ansible-swarm-subnet"
  network_id             = var.my_network["current_network"] # from credentials.auto.tfvars
  folder_id              = var.my_provider["folder"]         # from credentials.auto.tfvars
  network_zone           = var.my_network["zone_a"]          # from networks.auto.tfvars
  network_v4_cidr_blocks = ["10.128.2.32/28"]                # 10.128.2.34-10.128.2.46; next subnet: 10.128.2.48/28
}


module "key_vm_all_automation" {
  source        = "./modules/keys"
  key_srv_name  = "vm_all"
  key_user_name = "ansible"
}


#
# Description: SWARM one Master and two workers
#

# vm1 swarm-master

module "key_swarm-vm1_default" {
  source        = "./modules/keys"
  key_srv_name  = "swarm-vm1"
  key_user_name = "admin"
}

module "swarm-vm1" {
  source           = "./modules/srv"
#  srv_family       = "ubuntu-2004-lts"                      # Fluentd is absent for Ubuntu 22.04 (Jammy)
  srv_family       = "ubuntu-2204-lts"                      # (Jammy)
#  srv_family       = "ubuntu-1804-lts"                      # (Bionic)
  srv_default_user = "admin"                                # default ssh user
  srv_second_user  = "ansible"                              # second ssh user for automation
  srv_key1         = module.key_swarm-vm1_default.ssh_key_v       # default ssh user public key
  srv_key2         = module.key_vm_all_automation.ssh_key_v # second ssh user public key
  srv_name         = "vm1-swarm-master"
  srv_description  = "vm1 swarm-master"
  srv_zone         = var.my_network["zone_a"] # from networks.auto.tfvars
  # use standard-v3 for 50% core_fraction and standard-v1 (Intel Broadwell) for minumim server price (with 20% core_fraction) #
#  srv_platform_id   = "standard-v1"
  srv_platform_id   = "standard-v3"
  srv_core_fraction = "50"
  srv_cores         = 2
  srv_memory        = 8
#  srv_disk_size     = 20 # Size of the disk in GB
  srv_disk_size     = 30 # Size of the disk in GB
  srv_subnet        = module.network_ansible.created_id
  srv_ip            = "10.128.2.34"
  srv_nat           = "true" # If you create a balancer, an external address is needed!
}

# TODO: Put template code in a separate module to call on demand

#
# Local config file for manual configuration of IDE and Linux ssh_config
#
data "template_file" "ssh_config_ext2" {
  template = file("${path.module}/templates/.ssh/config_ext.tpl") # local path to template 
  vars = {
# tplt_vm_name - VM hostname (in arbitrary form) in this template is used to configure IDE (hostname) and to connection by SSH (ssh_config file)
    tplt_vm_name        = "vm1-swarm-master"
    tplt_public_ip      = module.swarm-vm1.public_address
  }
}

resource "null_resource" "update_ssh_config_ext2" {
  triggers = { # apply next block after rendered
    template = data.template_file.ssh_config_ext2.rendered
  }
  provisioner "local-exec" { # After rendered run local command 'echo'
# Export rendered template to directory server_data (filename ssh_config_ext2)
    command = "echo '${data.template_file.ssh_config_ext2.rendered}' > server_data/ssh_config_ext2"
  }
}
#
#

#
# Local script for connect to created VM
#
data "template_file" "ssh_connector2" {
  template = file("${path.module}/templates/.ssh/ssh_connector2.sh.tpl") # local path to template 
  vars = {
    tplt_key_path                     = "vm_all-ssh_key_ansible.pem"
    tplt_vm1_connector_public_ip      = module.swarm-vm1.private_address
    tplt_vm1_connector_ip             = module.swarm-vm1.private_address
    tplt_vm2_connector_ip             = module.swarm-vm2.private_address
    tplt_vm3_connector_ip             = module.swarm-vm3.private_address
  }
}

resource "null_resource" "update_ssh_connector2" {
  triggers = {
    template = data.template_file.ssh_connector2.rendered
  }
  provisioner "local-exec" {
# Export rendered template to directory server_data (filename ssh_connector2.sh)
    command = "echo '${data.template_file.ssh_connector2.rendered}' > server_data/ssh_connector2.sh && chmod ug+x server_data/ssh_connector2.sh"
  }
}


# vm2 swarm-node 1

module "key_swarm-vm2_default" {
  source        = "./modules/keys"
  key_srv_name  = "swarm-vm2"
  key_user_name = "admin"
}

module "swarm-vm2" {
  source           = "./modules/srv"
  srv_family       = "ubuntu-2204-lts"                      #
  srv_default_user = "admin"                                # default ssh user
  srv_second_user  = "ansible"                              # second ssh user for automation
  srv_key1         = module.key_swarm-vm2_default.ssh_key_v       # default ssh user public key
  srv_key2         = module.key_vm_all_automation.ssh_key_v # second ssh user public key
  srv_name         = "vm2-swarm-node1"
  srv_description  = "vm2 swarm-node 1"
  srv_zone         = var.my_network["zone_a"] # from networks.auto.tfvars
  # use standard-v3 for 50% core_fraction and standard-v1 (Intel Broadwell) for minumim server price (with 20% core_fraction) #
  srv_platform_id   = "standard-v1"
  srv_core_fraction = "20"
  srv_cores         = 2
  srv_memory        = 3
  srv_disk_size     = 15 # Size of the disk in GB
  srv_subnet        = module.network_ansible.created_id
  srv_ip            = "10.128.2.35"
  srv_nat           = "true" # If you create a balancer, an external address is needed!
}

# vm3 swarm-node 2

module "key_swarm-vm3_default" {
  source        = "./modules/keys"
  key_srv_name  = "swarm-vm3"
  key_user_name = "admin"
}

module "swarm-vm3" {
  source           = "./modules/srv"
  srv_family       = "ubuntu-2204-lts"                      #
  srv_default_user = "admin"                                # default ssh user
  srv_second_user  = "ansible"                              # second ssh user for automation
  srv_key1         = module.key_swarm-vm3_default.ssh_key_v       # default ssh user public key
  srv_key2         = module.key_vm_all_automation.ssh_key_v # second ssh user public key
  srv_name         = "vm3-swarm-node2"
  srv_description  = "vm3 swarm-node 2"
  srv_zone         = var.my_network["zone_a"] # from networks.auto.tfvars
  # use standard-v3 for 50% core_fraction and standard-v1 (Intel Broadwell) for minumim server price (with 20% core_fraction) #
  srv_platform_id   = "standard-v1"
  srv_core_fraction = "20"
  srv_cores         = 2
  srv_memory        = 3
  srv_disk_size     = 15 # Size of the disk in GB
  srv_subnet        = module.network_ansible.created_id
  srv_ip            = "10.128.2.36"
  srv_nat           = "true" # If you create a balancer, an external address is needed!
}


#
# DEPLOY SCRIPTS
#


# Create hosts file
data "template_file" "hosts2_file" {
  template = file("${path.module}/templates/hosts.tpl") # local path to template 
  vars = {
    tplt_hosts_key_path             = "../${module.key_vm_all_automation.ssh_key_filename_v}"
    tplt_hosts_username             = "ansible"
    tplt_hosts_vm1_address          = module.swarm-vm1.private_address
    tplt_hosts_vm2_address          = module.swarm-vm2.private_address
    tplt_hosts_vm3_address          = module.swarm-vm3.private_address   
    tplt_hosts_vm1_public_address   = module.swarm-vm1.public_address
  }
}

resource "null_resource" "create_hosts2_file" {
  triggers = {
    template = data.template_file.hosts2_file.rendered
  }
  provisioner "local-exec" {
    command = "echo '${data.template_file.hosts2_file.rendered}' > ansible/hosts"
  }
}

# An example from the Internet. Before starting the automation script, it is recommended to check the possibility of connecting by SSH
resource "null_resource" "run_deploy_scripts2" {
provisioner "remote-exec" {
    inline = ["date"]   # run remote command

    connection {
      type        = "ssh"
      host        = module.swarm-vm1.public_address
      user        = "ansible"
      private_key = "${file(module.key_vm_all_automation.ssh_key_filename_v)}"
    }

  }

provisioner "remote-exec" {
    inline = ["date"]

    connection {
      type        = "ssh"
      host        = module.swarm-vm2.public_address
      user        = "ansible"
      private_key = "${file(module.key_vm_all_automation.ssh_key_filename_v)}"
    }

  }

  provisioner "remote-exec" {
    inline = ["date"]

    connection {
      type        = "ssh"
      host        = module.swarm-vm3.public_address
      user        = "ansible"
      private_key = "${file(module.key_vm_all_automation.ssh_key_filename_v)}"
    }

  }

# SSH tests is completed

# Run the automation script (For any installations. I use Ansible roles)
  provisioner "local-exec" {
    command = "cd ansible && ansible-playbook -vvv -u ansible -i hosts --private-key '../${module.key_vm_all_automation.ssh_key_filename_v}' provision.yml"
  }
}

#
# // DEPLOY SCRIPTS
#

