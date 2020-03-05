resource "random_id" "instance_id" {
  count       = var.gcp_vpc_count
  byte_length = 8
}

resource "google_compute_instance" "vtor-vm" {
  count        = var.gcp_vpc_count
  name         = "${var.gcp_app_name}-vm-${element(random_id.instance_id.*.hex, count.index)}"
  hostname     = "${var.gcp_app_name}-vm-${element(random_id.instance_id.*.hex, count.index)}.${var.gcp_project}"
  machine_type = var.gcp_machine_type
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = var.gcp_image
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  metadata_startup_script = "sudo apt-get update"

  network_interface {
    network    = google_compute_network.vtor-vpc.name
    subnetwork = google_compute_subnetwork.vtor_private_subnet_1.name
    access_config {
    } 
  }
  
  tags = ["http","ssh"]
}

data "aws_route53_zone" "vtor_dns_zone" {
  name = var.aws_dns_main_zone_name
}

resource "aws_route53_record" "vtor_app_zone" {  
  zone_id = data.aws_route53_zone.vtor_dns_zone.zone_id
  name    = format("%s.%s", var.aws_dns_sub_zone_name, data.aws_route53_zone.vtor_dns_zone.name)
  type    = var.aws_dns_type_reord
  ttl     = var.aws_dns_ttl
  records = [google_compute_global_forwarding_rule.global_forwarding_rule.ip_address]
}

resource "null_resource" "ProductionHeader" {
  provisioner "local-exec" {
  command = <<-EOF
              #!/bin/bash
              echo "---" > production
              echo "all:" >> production
              echo "  children:" >> production
              echo "    app_web_vm:" >> production
              echo "      hosts:" >> production
              EOF
  }
}

resource "null_resource" "AppHostsAdd" {
  count        = var.gcp_vpc_count
  provisioner "local-exec" {
    command = "echo '        '${element(google_compute_instance.vtor-vm.*.network_interface.0.access_config.0.nat_ip, count.index)}:  >> production"
	}
  depends_on = [null_resource.ProductionHeader]
}



resource "null_resource" "ProductionHeader3"{
  provisioner "local-exec" {
    command = "ansible-playbook websrvs.yml"
  }
  depends_on = [aws_route53_record.vtor_app_zone]
}

output "name" {
  value = google_compute_instance.vtor-vm.*.name
}

output "internal-ip" {
  value = google_compute_instance.vtor-vm.*.network_interface.0.network_ip
}

output "external-ip" {
  value = google_compute_instance.vtor-vm.*.network_interface.0.access_config.0.nat_ip
}

output "instance_DNS_addresses" {
  value = [aws_route53_record.vtor_app_zone.name , aws_route53_record.vtor_app_zone.records]
}
