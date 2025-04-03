1. Make sure to change the key in ./terraform/ignition.tf to a key that was created via `ssh-keygen`
2. Make sure to run `terraform apply` with `sudo`, as specified pool path requires root privileges for write access
3. Make sure to place a qcow2 image of FCOS into ./terraform/images/ and specify it in ./terraform/main.tf "source"


1. If something doesn't work you can try to delete all .terraform files and try to init again
2. remove vols under /var/lib/libvirt/images/
3. ensure dnsmasq is started by doing `ps`
4. ensure ufw is not blocking traffic on a network port
```bash
sudo ip link delete virbr0

# and others
sudo virsh undefine --domain coreos01

virsh pool-destroy --pool fcos_k8s_lab_pool
virsh pool-undefine --pool fcos_k8s_lab_pool
```
