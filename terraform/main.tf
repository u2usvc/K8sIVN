terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
    ignition = {
      source = "community-terraform-providers/ignition"
      version = "2.5.1"
    }
  }
}

#################################
### Providers
#################################
provider "libvirt" {
  uri = "qemu:///system"
}

#################################
### Variables
#################################
variable "hosts" {
  default = 4
}

variable "hostname_format" {
  type    = string
  default = "coreos%02d"
}

# variable "libvirt_provider" {
#   type = string
# }

variable "mac_addresses" {
  type    = list(string)
  # E1 - CP master node
  # E2,F1 - DP worker nodes
  # F2 - monitoring host
  default = [
    "50:73:0F:31:81:E1",
    "50:73:0F:31:81:E2",
    "50:73:0F:31:81:F1",
    "50:73:0F:31:81:F2",
    "50:73:0F:31:81:F3"
  ]
}

#################################
### Resources
#################################
### NETWORK
resource "libvirt_network" "fcos_k8s_lab" {
  name      = "fcos_k8s_lab"
  mode      = "nat"
  bridge    = "k8sbr0"
  domain    = "k8s.local"
  addresses = ["192.168.122.0/24"]
  dhcp {
    enabled = true
  }
  dns {
    enabled = true
    forwarders {
      address = "1.1.1.1"
    }
  }

  # for static IP assigment. see ./dhcp_lease.xsl
  xml {
    xslt = file("dhcp_lease.xsl")
  }
}


### POOL
resource "libvirt_pool" "fcos_k8s_lab_pool" {
  name = "fcos_k8s_lab_pool"
  type = "dir"
  target {
    path = "/var/lib/libvirt/images/fcos_k8s_lab"
  }
}


### VOLUMES
resource "libvirt_volume" "coreos-disk" {
  name             = "${format(var.hostname_format, count.index + 1)}.qcow2"
  count            = var.hosts
  source = "./images/fedora-coreos-41.20250215.3.0-qemu.x86_64.qcow2"
  pool             = "fcos_k8s_lab_pool"
  format           = "qcow2"
  # fix the bug that doesn't allow to destroy a pool
  depends_on       = [libvirt_pool.fcos_k8s_lab_pool]
}

resource "libvirt_volume" "coreos-disk-attach" {
  name             = "${format(var.hostname_format, count.index + 1)}-attach.qcow2"
  count            = var.hosts
  # 5Gi for rook-ceph
  size             = "20111111111"
  pool             = "fcos_k8s_lab_pool"
  format           = "qcow2"
  # fix the bug that doesn't allow to destroy a pool
  depends_on       = [libvirt_pool.fcos_k8s_lab_pool]
}

# unpartitioned, unformated disk for rook
resource "libvirt_volume" "coreos-disk-rook" {
  name             = "${format(var.hostname_format, count.index + 1)}-rook.qcow2"
  count            = var.hosts
  size             = "6111111111"
  pool             = "fcos_k8s_lab_pool"
  format           = "qcow2"
  depends_on       = [libvirt_pool.fcos_k8s_lab_pool]
}


### IGNITION
# Loading ignition configs in QEMU requires at least QEMU v2.6
resource "libvirt_ignition" "ignition" {
  name    = "${format(var.hostname_format, count.index + 1)}-ignition"
  pool    = "fcos_k8s_lab_pool"
  count   = var.hosts
  content = element(data.ignition_config.startup.*.rendered, count.index)
  depends_on       = [libvirt_pool.fcos_k8s_lab_pool]
}


### DOMAIN
resource "libvirt_domain" "coreos-worker" {
  count  = var.hosts
  name   = format(var.hostname_format, count.index + 1)
  # 5vcpu - 5000m
  vcpu   = lookup({
    0 = 2,
    1 = 8,
    2 = 8,
    3 = 3,
    # 4 = 8
  }, count.index, 1) # Default to 1 if index is out of range

  memory  = lookup({
    0 = 4000,
    1 = 20000,
    2 = 20000,
    3 = 4000,
  }, count.index, 1)
  cpu {
      mode = "host-passthrough"
    }

  coreos_ignition = element(libvirt_ignition.ignition.*.id, count.index)

  disk {
    volume_id = element(libvirt_volume.coreos-disk.*.id, count.index)
  }
  disk {
    volume_id = element(libvirt_volume.coreos-disk-attach.*.id, count.index)
  }
  disk {
    volume_id = element(libvirt_volume.coreos-disk-rook.*.id, count.index)
  }

  # Makes the tty0 available via `virsh console`
  console {
    type = "pty"
    target_port = "0"
  }

  network_interface {
    network_name   = "fcos_k8s_lab"
    wait_for_lease = true
    mac            = element(var.mac_addresses, count.index)
  }
}

#################################
### Output
#################################
# output "ipv4" {
#   value = libvirt_domain.coreos-worker.*.network_interface.0.addresses
# }
