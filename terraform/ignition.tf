#################################
### ignition_config
#################################
### Define what ignition config is gonna use (e.g. in "files" array list all defined "ignition_file")
### THIS IS ORDERED!
data "ignition_config" "startup" {
  users = [
    # see data "ignition_user"
    data.ignition_user.core.rendered,
  ]

  files = [
    # see data "ignition_file"
    element(data.ignition_file.hostname.*.rendered, count.index),
    element(data.ignition_file.iptables.*.rendered, count.index),
    element(data.ignition_file.security_limits.*.rendered, count.index),
    element(data.ignition_file.br_netfilter.*.rendered, count.index),
    element(data.ignition_file.kubernetes_repo.*.rendered, count.index),
    element(data.ignition_file.allow_pass_ssh.*.rendered, count.index),
    element(data.ignition_file.setup_nameserver.*.rendered, count.index),
  ]

  # directories = [
  #   element(data.ignition_directory.mnt.*.rendered, count.index)
  # ]
  
  disks = [
    element(data.ignition_disk.rookdisk.*.rendered, count.index)
  ]

  filesystems = [
    element(data.ignition_filesystem.rookfs.*.rendered, count.index)
  ]


  count = var.hosts
}

# #################################
# ### ignition_directory
# #################################
# data "ignition_directory" "mnt" {
#   # will create a directory under /sysroot/$SPECIFIED_PATH
# # contain/vdb
#   path   = "/contain/vdb1"
#   count = var.hosts
# }


#################################
### ignition_file
#################################

# Replace the default hostname with our generated one
data "ignition_file" "hostname" {
  path       = "/etc/hostname"
  mode       = 420 # decimal 0644

  content {
    # see main.tf -> Variables
    content = format(var.hostname_format, count.index + 1)
  }

  # see main.tf -> Variables
  count = var.hosts
}

data "ignition_file" "iptables" {
  path       = "/etc/sysctl.d/90-kubernetes.conf"

  content {
    content = <<EOF
# These are required for it to work properly
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1

# This helps an issue later on when we get into running promtail
fs.inotify.max_user_instances = 256
    EOF
  }

  count = var.hosts
}

data "ignition_file" "security_limits" {
  path       = "/etc/security/limits.d/90-kubernetes.conf"

  content {
    content = <<EOF
* hard	nofile  10000
    EOF
  }

  count = var.hosts
}

data "ignition_file" "br_netfilter" {
  path       = "/etc/modules-load.d/br_netfilter.conf"
  mode       = 420 # decimal 0644
  overwrite  = true

  content {
    content = <<EOF
br_netfilter
    EOF
  }

  count = var.hosts
}

data "ignition_file" "kubernetes_repo" {
  path       = "/etc/yum.repos.d/kubernetes.repo"
  mode       = 420 # decimal 0644
  overwrite  = true

  content {
    content = <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
    EOF
  }

  count = var.hosts
}

data "ignition_file" "allow_pass_ssh" {
  path      = "/etc/ssh/sshd_config.d/40-disable-passwords.conf"
    overwrite = true

    content {
      content = <<EOF
PasswordAuthentication yes
        EOF
    }
}

data "ignition_file" "setup_nameserver" {
  path      = "/etc/resolv.conf"
    overwrite = true

    content {
      content = <<EOF
nameserver 1.1.1.1
        EOF
    }
}


#################################
### ignition_disk
#################################
data "ignition_disk" "rookdisk" {
  device = "/dev/vdb"
  partition {
    startmib = 0
    # fill the rest
    sizemib = 0
    label = "CONTAIN"
  }
  count = var.hosts
}

# for some reason label is not being created
data "ignition_filesystem" "rookfs" {
  device = "/dev/vdb1"
  format = "xfs"
# when mkdir, appends /sysroot
  # path   = "/../contain/vdb1"
  options = ["-L", "CONT"]
  count = var.hosts
}

#################################
### ignition_user
#################################
# Example configuration for the basic `core` user
data "ignition_user" "core" {
  name = "core"

  #Example password: foobar
  password_hash = "$5$pvB0zIw6$UXss4xgAgJlu.NjIRxrI0624lzoYqKjXyzAq8cSAGM0"
  # ssh_authorized_keys = [
  #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHhqUibd/DxikucOx/wE0W5pVytQ98IoN0O85eWfAC0Y spil@dc-1.aisp.aperture.local"
  # ]
}
