provider "scalingo" {
  api_token = var.scalingo_api_token
  alias     = "tmp"
}

provider "scalingo" {
  api_token = var.scalingo_api_token
  region    = data.scalingo_region.secnum_cloud.id
}
