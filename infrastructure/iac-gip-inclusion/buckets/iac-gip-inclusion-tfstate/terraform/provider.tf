provider "scaleway" {
  alias = "tmp"
}

provider "scaleway" {
  region     = var.scw_region
  zone       = var.scw_zone
  project_id = data.scaleway_account_project.terraform.project_id
}
