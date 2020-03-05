# create VPC
resource "google_compute_network" "vtor-vpc" {
  name = "${var.gcp_app_name}-vpc"
  auto_create_subnetworks = "false" 
  routing_mode = "GLOBAL"
}

resource "google_compute_subnetwork" "vtor_private_subnet_1" {
#  purpose = "PRIVATE"
  name = "${var.gcp_app_name}-private-subnet-1"
  ip_cidr_range = var.gcp_private_subnet_cidr_1
  network = google_compute_network.vtor-vpc.name
  region = var.gcp_region
}

# create a public ip for nat service
resource "google_compute_address" "nat-ip" {
  name = "${var.gcp_app_name}-nap-ip"
  project = var.gcp_project
  region  = var.gcp_region
}
# create a nat to allow private instances connect to internet
resource "google_compute_router" "nat-router" {
  name = "${var.gcp_app_name}-nat-router"
  network = google_compute_network.vtor-vpc.name
}
resource "google_compute_router_nat" "nat-gateway" {
  name = "${var.gcp_app_name}-nat-gateway"
  router = google_compute_router.nat-router.name
  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips = [ google_compute_address.nat-ip.self_link ]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES" 
  depends_on = [ google_compute_address.nat-ip ]
}
output "nat_ip_address" {
  value = google_compute_address.nat-ip.address
}
