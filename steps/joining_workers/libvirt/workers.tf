provider "libvirt" {
  uri = "${var.tectonic_libvirt_uri}"
}

resource "libvirt_volume" "worker" {
  count          = "${var.tectonic_worker_count}"
  name           = "worker${count.index}"
  base_volume_id = "${local.libvirt_base_volume_id}"
}

resource "libvirt_ignition" "worker" {
  name    = "worker.ign"
  content = "${file("${path.cwd}/${var.tectonic_ignition_worker}")}"
}

resource "libvirt_domain" "worker" {
  count = "${var.tectonic_worker_count}"

  name            = "worker${count.index}"
  memory          = "1024"
  vcpu            = "2"
  coreos_ignition = "${libvirt_ignition.worker.id}"

  disk {
    volume_id = "${element(libvirt_volume.worker.*.id, count.index)}"
  }

  console {
    type        = "pty"
    target_port = 0
  }

  network_interface {
    network_id = "${local.libvirt_network_id}"
    hostname   = "${var.tectonic_cluster_name}-worker-${count.index}"
    addresses  = ["${var.tectonic_libvirt_worker_ips[count.index]}"]
  }
}
