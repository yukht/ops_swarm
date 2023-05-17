[all:vars]
ansible_connection=ssh
ansible_user=${tplt_hosts_username}
ansible_ssh_private_key_file=${tplt_hosts_key_path}

# ansible_clients
[vm1]
${tplt_hosts_vm1_address}

[ansible1:vars]
my_public_address=${tplt_hosts_vm1_public_address}
