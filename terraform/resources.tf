/*
Copyright 2021 Google LLC
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    https://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

///////////////////////////////////////////////////////////////////////////////////////
// This configuration will create a gce vm and image
///////////////////////////////////////////////////////////////////////////////////////

# resource "random_id" "gce_base" {
#   byte_length = 4
#   prefix      = "tf-compute-"
# }

resource "random_id" "gce_image" {
  byte_length = 4
  prefix      = "tf-compute-"
}

data "google_compute_zones" "available" {
  region = var.region
}

// Randomize the Zone Choice
resource "random_shuffle" "gz" {
  input        = data.google_compute_zones.available.names
  result_count = 1
}

locals {
  random_zone = random_shuffle.gz.result[0]
#   random_zone_dest = random_shuffle.gz.result[1]
}

// Select Image to use for GCE Disk
data "google_compute_image" "base_image" {
  family  = "debian-10"
  project = "debian-cloud"
}

# // Create the GCE instance
# resource "google_compute_instance" "gce_base" {
#   zone         = local.random_zone
#   name         = random_id.gce_base.hex
#   machine_type = "f1-micro"
#   boot_disk {
#     initialize_params {
#       image = "${data.google_compute_image.base_image.project}/${data.google_compute_image.base_image.family}"
#     #   image = "debian-cloud/debian-9"
#     }
#   }
#   network_interface {
#     network = "default"
#     // Include this section to give the VM an external ip address
#     access_config {}
#   }
#   metadata_startup_script = "/usr/bin/systemctl poweroff"
# }

# resource "time_sleep" "wait_60_seconds" {
#   depends_on = [google_compute_instance.gce_base]
#   create_duration = "60s"
# }

// Create image from VM
// Had to shutdown the instance before creating the disk
// https://github.com/hashicorp/terraform-provider-google/issues/1983
# resource "google_compute_image" "custom_image" {
#   name = "custom-image"
#   project = var.project
#   family = data.google_compute_image.base_image.family
#   source_disk = "projects/${var.project}/zones/${google_compute_instance.gce_base.zone}/disks/${google_compute_instance.gce_base.name}"
#   depends_on = [
#     google_compute_instance.gce_base
#   ]
# }

// Create disk from base cloud image just to create a custom image later
resource "google_compute_disk" "base_disk" {
  name  = "base-disk"
  zone  = local.random_zone
  image = "${data.google_compute_image.base_image.project}/${data.google_compute_image.base_image.family}"
}

// Create image from disk
resource "google_compute_image" "custom_image" {
  name = "custom-image"
  project = var.project
  family = data.google_compute_image.base_image.family
  source_disk = "projects/${var.project}/zones/${google_compute_disk.base_disk.zone}/disks/${google_compute_disk.base_disk.name}"
  depends_on = [
    google_compute_disk.base_disk
  ]
}

// Create vm from image
resource "google_compute_instance" "gce_image" {
  zone         = local.random_zone
  name         = random_id.gce_image.hex
  machine_type = "f1-micro"
  boot_disk {
    initialize_params {
      image = google_compute_image.custom_image.name
    #   image = "debian-cloud/debian-10"
    }
  }
  network_interface {
    network = "default"
    // Include this section to give the VM an external ip address
    access_config {}
  }
}