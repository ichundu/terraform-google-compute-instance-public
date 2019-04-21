resource "google_compute_address" "instances" {
  count  = "${var.amount}"
  name   = "${var.name_prefix}-${count.index}"
  region = "${var.region}"
}

resource "google_compute_disk" "instances" {
  count = "${var.amount}"

  name = "${var.name_prefix}-${count.index+1}"
  type = "${var.disk_type}"
  size = "${var.disk_size}"

  # optional
  zone = "${var.zone}"

  image = "${var.disk_image}"

  provisioner "local-exec" {
    command    = "${var.disk_create_local_exec_command_or_fail}"
    on_failure = "fail"
  }

  provisioner "local-exec" {
    command    = "${var.disk_create_local_exec_command_and_continue}"
    on_failure = "continue"
  }

  provisioner "local-exec" {
    when       = "destroy"
    command    = "${var.disk_destroy_local_exec_command_or_fail}"
    on_failure = "fail"
  }

  provisioner "local-exec" {
    when       = "destroy"
    command    = "${var.disk_destroy_local_exec_command_and_continue}"
    on_failure = "continue"
  }
}

# https://www.terraform.io/docs/providers/google/r/compute_instance.html
resource "google_compute_instance" "instances" {
  count = "${var.amount}"

  name         = "${var.name_prefix}-${count.index+1}"
  tags         = "${var.tags}"
  zone         = "${var.zone}"
  machine_type = "${var.machine_type}"

  boot_disk = {
    source      = "${google_compute_disk.instances.*.name[count.index]}"
    auto_delete = false
  }

  # reference: https://cloud.google.com/compute/docs/storing-retrieving-metadata
  metadata {
    description = "Managed by Terraform"
    user-data   = "${replace(replace(var.user_data, "$$ZONE", var.zone), "$$REGION", var.region)}"
    ssh-keys    = "${var.username}:${file("${var.public_key_path}")}"
  }

  network_interface = {
    network    = "${var.network}"
    subnetwork = "${var.subnetwork}"

    access_config = {
      nat_ip = "${google_compute_address.instances.*.address[count.index]}"
    }
  }

  scheduling {
    on_host_maintenance = "MIGRATE"
    automatic_restart   = "${var.automatic_restart}"
  }

  allow_stopping_for_update = "true"
}
