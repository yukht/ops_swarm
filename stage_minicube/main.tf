variable "my_network" {
  # Variable settings see in credentials.auto.tfvars
  description = "network settings"
  type        = map(string)
}

module "network_ansible" {
  source                 = "./modules/network"
  network_description    = "Подсеть для серверов K8"
  network_name           = "kube-subnet"
  network_id             = var.my_network["current_network"] # from credentials.auto.tfvars
  folder_id              = var.my_provider["folder"]         # from credentials.auto.tfvars
  network_zone           = var.my_network["zone_a"]          # from networks.auto.tfvars
  network_v4_cidr_blocks = ["10.128.2.48/28"]                # 10.128.2.49-10.128.2.62; next subnet: 10.128.2.64/28
}


module "key_vm_all_automation" {
  source        = "./modules/keys"
  key_srv_name  = "vm_all"
  key_user_name = "ansible"
}


#
# Description: Kube one Master and two workers
#

# vm1 kube-master

module "key_kube-vm1_default" {
  source        = "./modules/keys"
  key_srv_name  = "kube-vm1"
  key_user_name = "admin"
}

module "kube-vm1" {
  source           = "./modules/srv"
#  srv_family       = "ubuntu-2004-lts"                      # Fluentd is absent for Ubuntu 22.04 (Jammy)
  srv_family       = "ubuntu-2204-lts"                      # (Jammy)
#  srv_family       = "ubuntu-1804-lts"                      # (Bionic)
  srv_default_user = "admin"                                # default ssh user
  srv_second_user  = "ansible"                              # second ssh user for automation
  srv_key1         = module.key_kube-vm1_default.ssh_key_v       # default ssh user public key
  srv_key2         = module.key_vm_all_automation.ssh_key_v # second ssh user public key
  srv_name         = "vm1-kube-master"
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
  srv_ip            = "10.128.2.49"
  srv_nat           = "true" # If you create a balancer, an external address is needed!
}

# TODO: Put template code in a separate module to call on demand

#
# Local config file for manual configuration of IDE and Linux ssh_config
#
data "template_file" "ssh_config_ext" {
  template = file("${path.module}/templates/.ssh/config_ext.tpl") # local path to template 
  vars = {
# tplt_vm_name - VM hostname (in arbitrary form) in this template is used to configure IDE (hostname) and to connection by SSH (ssh_config file)
    tplt_vm_name        = "vm1-kube-master"
    tplt_public_ip      = module.kube-vm1.public_address
  }
}

resource "null_resource" "update_ssh_config_ext" {
  triggers = { # apply next block after rendered
    template = data.template_file.ssh_config_ext.rendered
  }
  provisioner "local-exec" { # After rendered run local command 'echo'
# Export rendered template to directory server_data (filename ssh_config_ext)
    command = "echo '${data.template_file.ssh_config_ext.rendered}' > server_data/ssh_config_ext"
  }
}
#
#

#
# Local script for connect to created VM
#
data "template_file" "ssh_connector" {
  template = file("${path.module}/templates/.ssh/ssh_connector.sh.tpl") # local path to template 
  vars = {
    tplt_key_path                     = "vm_all-ssh_key_ansible.pem"
    tplt_vm1_connector_public_ip      = module.kube-vm1.private_address
    tplt_vm1_connector_ip             = module.kube-vm1.private_address
    /* tplt_vm2_connector_ip             = module.kube-vm2.private_address
    tplt_vm3_connector_ip             = module.kube-vm3.private_address
    tplt_vm4_connector_ip             = module.kube-vm4.private_address */
  }
}

resource "null_resource" "update_ssh_connector" {
  triggers = {
    template = data.template_file.ssh_connector.rendered
  }
  provisioner "local-exec" {
# Export rendered template to directory server_data (filename ssh_connector.sh)
    command = "echo '${data.template_file.ssh_connector.rendered}' > server_data/ssh_connector.sh && chmod ug+x server_data/ssh_connector.sh"
  }
}

/*
# TEMPORARY DISABLED

# vm2 kube-worker 1

module "key_kube-vm2_default" {
  source        = "./modules/keys"
  key_srv_name  = "kube-vm2"
  key_user_name = "admin"
}

module "kube-vm2" {
  source           = "./modules/srv"
  srv_family       = "ubuntu-2204-lts"                      #
  srv_default_user = "admin"                                # default ssh user
  srv_second_user  = "ansible"                              # second ssh user for automation
  srv_key1         = module.key_kube-vm2_default.ssh_key_v       # default ssh user public key
  srv_key2         = module.key_vm_all_automation.ssh_key_v # second ssh user public key
  srv_name         = "vm2-kube-worker1"
  srv_description  = "vm2 kube-worker 1"
  srv_zone         = var.my_network["zone_a"] # from networks.auto.tfvars
  # use standard-v3 for 50% core_fraction and standard-v1 (Intel Broadwell) for minumim server price (with 20% core_fraction) #
  srv_platform_id   = "standard-v1"
  srv_core_fraction = "20"
  srv_cores         = 2
  srv_memory        = 3
  srv_disk_size     = 15 # Size of the disk in GB
  srv_subnet        = module.network_ansible.created_id
  srv_ip            = "10.128.2.50"
  srv_nat           = "true" # If you create a balancer, an external address is needed!
}

# vm3 kube-worker 2

module "key_kube-vm3_default" {
  source        = "./modules/keys"
  key_srv_name  = "kube-vm3"
  key_user_name = "admin"
}

module "kube-vm3" {
  source           = "./modules/srv"
  srv_family       = "ubuntu-2204-lts"                      #
  srv_default_user = "admin"                                # default ssh user
  srv_second_user  = "ansible"                              # second ssh user for automation
  srv_key1         = module.key_kube-vm3_default.ssh_key_v       # default ssh user public key
  srv_key2         = module.key_vm_all_automation.ssh_key_v # second ssh user public key
  srv_name         = "vm3-kube-worker2"
  srv_description  = "vm3 kube-worker 2"
  srv_zone         = var.my_network["zone_a"] # from networks.auto.tfvars
  # use standard-v3 for 50% core_fraction and standard-v1 (Intel Broadwell) for minumim server price (with 20% core_fraction) #
  srv_platform_id   = "standard-v1"
  srv_core_fraction = "20"
  srv_cores         = 2
  srv_memory        = 3
  srv_disk_size     = 15 # Size of the disk in GB
  srv_subnet        = module.network_ansible.created_id
  srv_ip            = "10.128.2.51"
  srv_nat           = "true" # If you create a balancer, an external address is needed!
}

# vm3 kube-worker 3

module "key_kube-vm4_default" {
  source        = "./modules/keys"
  key_srv_name  = "kube-vm3"
  key_user_name = "admin"
}

module "kube-vm4" {
  source           = "./modules/srv"
  srv_family       = "ubuntu-2204-lts"                      #
  srv_default_user = "admin"                                # default ssh user
  srv_second_user  = "ansible"                              # second ssh user for automation
  srv_key1         = module.key_kube-vm4_default.ssh_key_v       # default ssh user public key
  srv_key2         = module.key_vm_all_automation.ssh_key_v # second ssh user public key
  srv_name         = "vm4-kube-worker3"
  srv_description  = "vm4 kube-worker 3"
  srv_zone         = var.my_network["zone_a"] # from networks.auto.tfvars
  # use standard-v3 for 50% core_fraction and standard-v1 (Intel Broadwell) for minumim server price (with 20% core_fraction) #
  srv_platform_id   = "standard-v1"
  srv_core_fraction = "20"
  srv_cores         = 2
  srv_memory        = 3
  srv_disk_size     = 15 # Size of the disk in GB
  srv_subnet        = module.network_ansible.created_id
  srv_ip            = "10.128.2.52"
  srv_nat           = "true" # If you create a balancer, an external address is needed!
}

## // TEMPORARY DISABLED

*/

#
# DEPLOY SCRIPTS
#


# Create hosts file
data "template_file" "hosts_file" {
  template = file("${path.module}/templates/hosts.tpl") # local path to template 
  vars = {
    tplt_hosts_key_path             = "../${module.key_vm_all_automation.ssh_key_filename_v}"
    tplt_hosts_username             = "ansible"
    tplt_hosts_vm1_address          = module.kube-vm1.private_address
    /* tplt_hosts_vm2_address          = module.kube-vm2.private_address
    tplt_hosts_vm3_address          = module.kube-vm3.private_address   
    tplt_hosts_vm4_address          = module.kube-vm3.private_address    */
    tplt_hosts_vm1_public_address   = module.kube-vm1.public_address
  }
}

resource "null_resource" "create_hosts_file" {
  triggers = {
    template = data.template_file.hosts_file.rendered
  }
  provisioner "local-exec" {
    command = "echo '${data.template_file.hosts_file.rendered}' > ansible/hosts"
  }
}


# DISABLE AUTOMATION AND OTHER 3 VM

/*

# An example from the Internet. Before starting the automation script, it is recommended to check the possibility of connecting by SSH
resource "null_resource" "run_deploy_scripts2" {
provisioner "remote-exec" {
    inline = ["date"]   # run remote command

    connection {
      type        = "ssh"
      host        = module.kube-vm1.public_address
      user        = "ansible"
      private_key = "${file(module.key_vm_all_automation.ssh_key_filename_v)}"
    }

  }

provisioner "remote-exec" {
    inline = ["date"]

    connection {
      type        = "ssh"
      host        = module.kube-vm2.public_address
      user        = "ansible"
      private_key = "${file(module.key_vm_all_automation.ssh_key_filename_v)}"
    }

  }

  provisioner "remote-exec" {
    inline = ["date"]

    connection {
      type        = "ssh"
      host        = module.kube-vm3.public_address
      user        = "ansible"
      private_key = "${file(module.key_vm_all_automation.ssh_key_filename_v)}"
    }

  }

  provisioner "remote-exec" {
    inline = ["date"]

    connection {
      type        = "ssh"
      host        = module.kube-vm4.public_address
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

## AUTOMATION TEMPORARY DISABLED
*/

#
# // DEPLOY SCRIPTS
#

