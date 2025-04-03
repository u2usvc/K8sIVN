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

create password with `mkpasswd --method=sha-256`

```bash
cd terraform
terraform init
terraform apply
cd ..
```

```bash
cd ansible
ansible-playbook -i inventory.ini ./cluster-setup.yaml
```



```
TASK [Add Rook Helm repository] ********************************************************************************************************************************
fatal: [kmn1]: FAILED! => {"changed": false, "command": "/usr/bin/helm repo add rook-release https://charts.rook.io/release", "msg": "Failure when executing Helm command. Exited 1.\nstdout: \nstderr: Error: looks like \"https://charts.rook.io/release\" is not a valid chart repository or cannot be reached: local error: tls: bad record MAC\n", "stderr": "Error: looks like \"https://charts.rook.io/release\" is not a valid chart repository or cannot be reached: local error: tls: bad record MAC\n", "stderr_lines": ["Error: looks like \"https://charts.rook.io/release\" is not a valid chart repository or cannot be reached: local error: tls: bad record MAC"], "stdout": "", "stdout_lines": []}



TASK [Install Kyverno] *****************************************************************************************************************************************
fatal: [kmn1]: FAILED! => {"changed": false, "command": "/usr/bin/helm show chart 'kyverno/kyverno'", "msg": "Failure when executing Helm command. Exited 1.\nstdout: \nstderr: Error: local error: tls: bad record MAC\n", "stderr": "Error: local error: tls: bad record MAC\n", "stderr_lines": ["Error: local error: tls: bad record MAC"], "stdout": "", "stdout_lines": []}



TASK [Add Rook Helm repository] ********************************************************************************************************************************
fatal: [kmn1]: FAILED! => {"changed": false, "command": "/usr/bin/helm repo add rook-release https://charts.rook.io/release", "msg": "Failure when executing Helm command. Exited 1.\nstdout: \nstderr: Error: looks like \"https://charts.rook.io/release\" is not a valid chart repository or cannot be reached: Get \"https://charts.rook.io/release/index.yaml\": local error: tls: bad record MAC\n", "stderr": "Error: looks like \"https://charts.rook.io/release\" is not a valid chart repository or cannot be reached: Get \"https://charts.rook.io/release/index.yaml\": local error: tls: bad record MAC\n", "stderr_lines": ["Error: looks like \"https://charts.rook.io/release\" is not a valid chart repository or cannot be reached: Get \"https://charts.rook.io/release/index.yaml\": local error: tls: bad record MAC"], "stdout": "", "stdout_lines": []}
```

http://grafana.monitoring.svc.cluster.local


echo "10.100.49.219 grafana.k8s.local" | sudo tee -a /etc/hosts
