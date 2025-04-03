#!/bin/bash
RED='\e[0;31m'
YELLOW='\e[0;33m'
GREEN='\e[0;32m'
NC='\e[0m' # No Color
# interupt script on fail
set -e

cd ./terraform/

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
sleep 3
sudo terraform destroy -auto-approve
echo -e "${YELLOW}###########################################${NC}"
echo -e "${YELLOW}[X] Providing the cluster${NC}"
echo -e "${YELLOW}###########################################${NC}"
sudo terraform apply -auto-approve && echo -e "${GREEN}[+] Cluster is deployed${NC}"

echo -e "${YELLOW}###########################################${NC}"
echo -e "${YELLOW}[X] About to provision the cluster${NC}"
echo -e "${YELLOW}[X] Passing execution flow to Ansible${NC}"
echo -e "${YELLOW}###########################################${NC}"
sleep 4
cd ../ansible/

sed -i '/192.168.122.101\|192.168.122.102\|192.168.122.103\|192.168.122.104/d' ~/.ssh/known_hosts
ansible-playbook -i inventory.ini ./playbook.yaml

cd ../
