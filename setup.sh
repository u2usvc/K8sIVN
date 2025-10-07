#!/bin/bash
RED='\e[0;31m'
YELLOW='\e[0;33m'
GREEN='\e[0;32m'
NC='\e[0m' # No Color
# interupt script on fail
set -e

echo -e "${YELLOW}Select provider:${NC}"
echo "1) libvirt"
echo "2) proxmox"

read -rp "Enter your choice [1-2]: " choice

case "$choice" in
1) cd ./terraform/libvirt/ ;;
2) cd ./terraform/proxmox/ ;;
*)
  echo -e "${RED}Invalid choice. Exiting.${NC}"
  exit 1
  ;;
esac

echo -e "${GREEN}Changed directory to $(pwd)${NC}"

mkdir -p images

# download FCOS
cd ./images/
if ls fedora-core* &>/dev/null; then
  echo -e "${YELLOW}###########################################${NC}"
  echo -e "${YELLOW}[>] FCOS image exists. Skipping the download${NC}"
  echo -e "${YELLOW}###########################################${NC}"
else
  echo -e "${YELLOW}[X] Downloading FCOS${NC}" && sleep 1
  wget https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/41.20250215.3.0/x86_64/fedora-coreos-41.20250215.3.0-qemu.x86_64.qcow2.xz
  echo -e "${YELLOW}[X] Unpacking FCOS${NC}"
  unxz fedora-coreos-41.20250215.3.0-qemu.x86_64.qcow2.xz
fi
sleep 1

cd ..
echo -e "${YELLOW}###########################################${NC}"
echo -e "${YELLOW}[X] Destroying existing plan if any${NC}"
echo -e "${YELLOW}###########################################${NC}"
sleep 5
terraform destroy -auto-approve
echo -e "${YELLOW}###########################################${NC}"
echo -e "${YELLOW}[X] Providing the cluster${NC}"
echo -e "${YELLOW}###########################################${NC}"
sleep 5
terraform apply -auto-approve && echo -e "${GREEN}[+] Cluster is deployed${NC}"

echo -e "${YELLOW}###########################################${NC}"
echo -e "${YELLOW}[X] About to provision the cluster${NC}"
echo -e "${YELLOW}[X] Passing execution flow to Ansible${NC}"
echo -e "${YELLOW}###########################################${NC}"
sleep 4
cd ../ansible/

ssh-keygen -f ~/.ssh/known_hosts -R 192.168.190.101
ssh-keygen -f ~/.ssh/known_hosts -R 192.168.190.102
ssh-keygen -f ~/.ssh/known_hosts -R 192.168.190.103
ssh-keygen -f ~/.ssh/known_hosts -R 192.168.190.104

ansible-playbook -i inventory.ini playbooks/imports.yml

cd ../
