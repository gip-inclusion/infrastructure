# Only used for the data source
provider "scaleway" {
  alias = "tmp"
}

provider "scaleway" {
  region     = var.scw_default_region
  zone       = var.scw_default_zone
  project_id = data.scaleway_account_project.emplois_cnav.id
}
