module "dns-emplois" {
  source = "./dns"

  providers = { scaleway = scaleway.terraform_ci }

  organization_id = var.scw_organization_id
  managed         = local.managed
  records = {
    "emplois-brevo-code" : {
      name = "emplois"
      data = "brevo-code:7a18495fb1b2ffa39ca7ad0c1e70adcb"
      type = "TXT"
    },
    "emplois-website" = {
      name = "emplois"
      data = "domain.par.clever-cloud.com."
      type = "ALIAS"
    },
  }
}
