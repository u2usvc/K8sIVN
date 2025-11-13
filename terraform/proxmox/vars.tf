variable "hosts" {
  type    = number
  default = 4
}

variable "pve_ssh_key_path" {
  type    = string
  default = ""
}

variable "node_fqdn" {
  type    = string
  default = ""
}

variable "hostname_format" {
  type    = string
  default = "coreos%02d"
}

variable "node_name" {
  type    = string
  default = "pve"
}

variable "datastore" {
  type    = string
  default = "local-lvm"
}

variable "local_datastore" {
  type    = string
  default = "local"
}

variable "vm_id_start" {
  type    = number
  default = 910
}

variable "mac_addresses" {
  type = list(string)
  default = [
    "50:73:0F:31:81:E1",
    "50:73:0F:31:81:E2",
    "50:73:0F:31:81:F1",
    "50:73:0F:31:81:F2"
  ]
}

# variable "static_ips" {
#   type = list(string)
#   default = [
#     "192.168.88.41/24",
#     "192.168.88.42/24",
#     "192.168.88.43/24",
#     "192.168.88.44/24"
#   ]
# }

variable "bridge" {
  type    = string
  default = "vmbr0" # change to k8sbr0 if your Proxmox bridge is named differently
}
