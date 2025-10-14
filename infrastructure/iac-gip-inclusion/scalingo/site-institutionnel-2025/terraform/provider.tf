provider "scalingo" {
  api_token = var.scalingo_api_token
  region    = data.secnum_cloud.id
}
