This project additionally integrates 
1. Prometheus + Grafana
2. Cilium
3. Kyverno
4. Rook-ceph

Before running the setup.sh, make sure to initialize the terraform project

1. If something doesn't work you can try to delete all .terraform files and try to init again
2. remove vols under /var/lib/libvirt/images/
3. ensure dnsmasq is started by doing `ps`
4. ensure ufw is not blocking traffic on a network port

If a script fails to remove the existing cluster, you can undefine it manually:
```bash
sudo ip link delete virbr0

sudo virsh undefine --domain coreos01

virsh pool-destroy --pool fcos_k8s_lab_pool
virsh pool-undefine --pool fcos_k8s_lab_pool
```
