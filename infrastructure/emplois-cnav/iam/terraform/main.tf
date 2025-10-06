terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "2.60.0"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_iam_ssh_key" "leo" {
  name       = "leo"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKEL9IfV8A/AssY0xT7MamKHag/x5U5SKuSf7fFw+kP5"
}
