#!/bin/bash
if [ -z "$1" ]
  then
    echo "No argument supplied, connecting to -- VM1 --"
    ssh-keygen -f "/root/.ssh/known_hosts" -R "${tplt_public_ip}"
    ssh -i vm_all-ssh_key_ansible.pem ansible@${tplt_public_ip}
  else
    case $1 in
      1)
        echo "Connecting to -- VM$1 --"
        ssh-keygen -f "/root/.ssh/known_hosts" -R "${tplt_public_ip}"
        ssh -i vm_all-ssh_key_ansible.pem ansible@${tplt_public_ip}
        ;;
      2)
        echo "Connecting to -- VM$1 --"
        ssh-keygen -f "/root/.ssh/known_hosts" -R "10.128.2.11"
        ssh -i vm_all-ssh_key_ansible.pem ansible@10.128.2.11
        ;;
      3)
        echo "Connecting to -- VM$1 --"
        ssh-keygen -f "/root/.ssh/known_hosts" -R "10.128.2.12"
        ssh -i vm_all-ssh_key_ansible.pem ansible@10.128.2.12
        ;;
      *)
        echo "No VM number $1 found, exit"
    esac
fi
