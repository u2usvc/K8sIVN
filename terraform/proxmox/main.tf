terraform {
  required_version = ">= 0.13"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.86.0"
    }
    ignition = {
      source  = "community-terraform-providers/ignition"
      version = "2.5.1"
    }
  }
}

provider "proxmox" {
}

# resource "proxmox_virtual_environment_file" "ignition" {
#   count        = var.hosts
#   node_name    = var.node_name
#   datastore_id = var.local_datastore
#   content_type = "snippets"
#   # content    = element(data.ignition_config.startup.*.rendered, count.index)
#   # data       = "${format(var.hostname_format, count.index + 1)}-ignition"
#   source_raw {
#     # data      = element(local.cloudconfigs, count.index)
#     data = element(data.ignition_config.startup.*.rendered, count.index)
#     # file_name = "${format(var.hostname_format, count.index + 1)}-cloudinit.yaml"
#     file_name = "${format(var.hostname_format, count.index + 1)}-ignition.ign"
#   }
# }

# resource "proxmox_virtual_environment_file" "cloudinit" {
#   count        = var.hosts
#   node_name    = var.node_name
#   datastore_id = var.snippets_datastore
#   content_type = "snippets"
#   source_raw {
#     data      = element(local.cloudconfigs, count.index)
#     file_name = "${format(var.hostname_format, count.index + 1)}-cloudinit.yaml"
#   }
# }

# resource "proxmox_virtual_environment_file" "fcos_image" {
#   count        = 1
#   node_name    = var.node_name
#   datastore_id = var.snippets_datastore
#   content_type = "import"
#
#   source_file {
#     path = var.fcos_url
#   }
# }

resource "proxmox_virtual_environment_vm" "coreos" {
  count     = var.hosts
  name      = format(var.hostname_format, count.index + 1)
  node_name = var.node_name
  vm_id     = var.vm_id_start + count.index
  tags      = ["k8sivn"]
  # kvm_arguments = "-fw_cfg name=opt/com.coreos/config,file=/var/lib/vz/snippets/${format(var.hostname_format, count.index + 1)}-ignition.ign"
  # comma is a reserved char in kvm_arguments
  # {https://blog.cloudbending.dev/posts/fedora-coreos-on-proxmox/}
  kvm_arguments = format(
    "-fw_cfg 'name=opt/com.coreos/config,string=%s'",
    replace(trimspace(data.ignition_config.startup[count.index].rendered), ",", ",,")
  )

  cpu {
    cores = lookup({ 0 = 2, 1 = 8, 2 = 8, 3 = 3 }, count.index, 1)
    type  = "host"
  }

  memory {
    dedicated = lookup({ 0 = 4000, 1 = 20000, 2 = 20000, 3 = 4000 }, count.index, 2048)
  }

  disk {
    datastore_id = var.datastore
    interface    = "scsi0"
    size         = 30
    # import_from  = "local:iso/fedora-coreos-41.raw"
    file_id = "local:iso/fedora-coreos-41.iso"
  }

  disk {
    datastore_id = var.datastore
    interface    = "virtio1"
    size         = 30
  }

  disk {
    datastore_id = var.datastore
    interface    = "virtio2"
    size         = 30
  }

  network_device {
    bridge      = var.bridge
    model       = "virtio"
    mac_address = element(var.mac_addresses, count.index)
  }

  # initialization {
  #   datastore_id      = var.local_datastore
  #   user_data_file_id = element(proxmox_virtual_environment_file.ignition.*.id, count.index)
  # }

  # agent {
  #   enabled = true
  # }

  serial_device {}

  lifecycle {
    create_before_destroy = true
  }
}
