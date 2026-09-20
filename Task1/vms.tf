resource "yandex_compute_instance" "vm" {
  count = 2

  name        = format("%s-%d", var.instance_name, count.index)
  platform_id = "standard-v1"

  boot_disk {
    initialize_params {
        image_id = var.image_id 
        size = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet1.id
    nat                = true    
  }

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  scheduling_policy { preemptible = true }

  metadata = {
    ssh-keys = "terraform:${file("/my_vm_key.pub")}"
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo apt update", 
      "sudo DEBIAN_FRONTEND=noninteractive apt install -y nginx", 
      "sudo systemctl enable nginx", 
      "sudo systemctl start nginx" 
      ]
    connection { 
      type = "ssh" 
      user = "terraform"
      private_key = file("/my_vm_key") 
      host = self.network_interface.0.nat_ip_address
    } 
  }
}





