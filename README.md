## About

This is an IaC FCOS-based K8s cluster deployment utilizing `terraform-provider-libvirt` (or `bpg/proxmox` provider).

The cluster is pretty resource-heavy. You can look up the resource allocation under `./terraform/main.tf` (vcpu, memory).

Before running the setup.sh, make sure to initialize the terraform project.

1. If something doesn't work you can try to delete all .terraform files and try to init again
2. remove vols under /var/lib/libvirt/images/
3. ensure dnsmasq is started by doing `ps`
4. ensure ufw is not blocking traffic on a network port
5. ensure images created under the pool path have appropriate (e.g. $USER:kvm) permissions

If a script fails to remove the existing cluster resources (e.g. if you manually removed tf state files), you can undefine them manually:

```bash
sudo virsh undefine --domain coreos01

virsh pool-destroy --pool fcos_k8s_lab_pool
virsh pool-undefine --pool fcos_k8s_lab_pool
```

## Prerequisites

1. terraform, libvirt, jq and qemu should be installed.
2. xsltproc should be installed
3. `libvirtd` should be running.
4. ensure your user is a member of `libvirt` group

## Usage

## Libvirt deployment

This project uses libvirt `qemu:///system`

Initialize terraform project:

```bash
cd ./terraform/libvirt && terraform init -upgrade
```

In order to achieve basic cluster deployment - exclude unwanted playbooks from `./ansible/playbooks/imports.yml`

Install ansible

```bash
cd ansible
python -m venv ./
. ./bin/activate

# libssh-devel is required
sudo apt install sshpass
pip install ansible==11.8.0 ansible-pylibssh
```

Execute the deployment script:

```bash
./setup.sh
```

## Alternative: proxmox deployment

1. Generate Proxmox API token.
2. Create a file under `./terraform/proxmox/.env` and write that API token into it as so: `PROXMOX_VE_API_TOKEN=ffffffff-ffff-ffff-ffff-ffffffffffff`
3. ensure `vars.tf > snippets_datastore` indeed supports snippets and imports by editing it under `Datacenter > Storage > $DATASTORE > Edit > Content`
4. ensure you have your key imported to the remote PVE host: `ssh-copy-id -i $TF_VAR_pve_ssh_key_path root@pve.aperture.ad`

Execute the deployment script:

```bash
./setup.sh
```

## Accessing the cluster

After deployment, you may directly ssh into one of the hosts in `./ansible/inventory.ini`, the password is `foobar`.

```bash
ssh core@192.168.190.101
```

Optionally, add these domains to `/etc/hosts`:

```bash
### /etc/hosts
# add coreos04
192.168.190.104 gitlab.k8s.local
# add ingress
192.168.190.103 grafana.k8s.local
192.168.190.103 vulnapp.k8s.local
```

To add or remove functionality within the deployment - edit:

1. `./ansible/playbooks/imports.yml` - to import/remove playbooks
2. `./ansible/playbooks/$PLAYBOOK` - to add/remove roles to a specific playbook
3. `./ansible/roles/*` - roles dir
