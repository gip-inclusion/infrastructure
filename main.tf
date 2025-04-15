module "bootstrap" {
  source = "./bootstrap"

  providers       = { scaleway = scaleway.terraform_ci }
  organization_id = var.scw_organization_id

  managed = local.managed
}

output "ci_access_key" {
  value     = module.bootstrap.ci_access_key
  sensitive = true
}

output "ci_secret_key" {
  value     = module.bootstrap.ci_secret_key
  sensitive = true
}
