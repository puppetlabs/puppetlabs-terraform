terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
  }
}

# Configure the Docker provider
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Create n sshd servers, map internal ports
resource "docker_container" "sshd" {
  image = "${docker_image.sshd.latest}"
  count = "1"
  name  = "docker_target_${count.index}"
  ports {
    internal = 22
    external = 2200 + count.index
  }
}

resource "docker_image" "sshd" {
  name = "rastasheep/ubuntu-sshd"
}

variable "tfstatevar" {
  type = string
}

variable "clivar" {
  type = string
  default = "override"
}

output "terraform_output" {
  value = { 
    "tfstatevar": "${var.tfstatevar}",
    "clivar": "${var.clivar}"
  }
}
