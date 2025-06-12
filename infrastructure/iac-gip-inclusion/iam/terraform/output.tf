output "ci_access_key" {
  value     = scaleway_iam_api_key.terraform_ci_api_key.access_key
  sensitive = true
}

output "ci_secret_key" {
  value     = scaleway_iam_api_key.terraform_ci_api_key.secret_key
  sensitive = true
}
