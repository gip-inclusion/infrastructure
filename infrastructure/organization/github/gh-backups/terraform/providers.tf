provider "scaleway" {
  region = var.scw_region
  zone   = var.scw_zone
}

provider "github" {
  owner = var.github_owner
}
