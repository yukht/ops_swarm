Host ${tplt_vm_name}
	IdentityFile ~/.ssh/vm_all-ssh_key_ansible.pem
	HostName ${tplt_public_ip}
	User root
	Port 22
