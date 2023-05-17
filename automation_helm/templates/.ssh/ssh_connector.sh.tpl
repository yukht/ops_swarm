#!/bin/bash
if [ -z "$1" ]
  then
    echo "No argument supplied, connecting to -- VM1 --"
    ssh-keygen -f "/root/.ssh/known_hosts" -R "${tplt_vm1_connector_ip}"
    ssh -i vm_all-ssh_key_ansible.pem ansible@${tplt_vm1_connector_ip}
  else
    case $1 in
      1)
        echo "Connecting to -- VM$1 --"
        ssh-keygen -f "/root/.ssh/known_hosts" -R "${tplt_vm1_connector_ip}"
        ssh -i vm_all-ssh_key_ansible.pem ansible@${tplt_vm1_connector_ip}
        ;;
      *)
        echo "No VM number $1 found, exit"
    esac
fi
