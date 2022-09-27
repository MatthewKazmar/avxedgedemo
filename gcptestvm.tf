#Deploy test VM

#Create VM PIP
resource "google_compute_address" "test_vm_pip" {
  name = "${local.test_vm_name}-pip"
}

#Create the VM
resource "google_compute_instance" "test_vm" {

  name                      = local.test_vm_name
  machine_type              = var.test_vm_size
  zone                      = data.google_compute_zones.available.names[0]
  allow_stopping_for_update = true

  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20220902"
      size  = 10
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.vpc_subnet.self_link
    network_ip = local.test_vm_vpc_ip
    nic_type   = "GVNIC"
    access_config {
      nat_ip = resource.google_compute_address.test_vm_pip.address
    }
  }


  metadata = {
    user-data = file("${path.module}/test-cloud-init.yaml")
    ssh-keys  = local.vm_ssh_key
  }

  lifecycle {
    ignore_changes = [
      metadata["ssh-keys"]
    ]
  }
}