module "dns-marche" {
  source = "./dns"

  providers = { scaleway = scaleway.terraform_ci }

  organization_id = var.scw_organization_id
  managed         = local.managed
  records = {
    "brevo-code-marche" = {
      name = ""
      data = "brevo-code:96720ae72c4b9e35f0b138dac0f441c4"
      type = "TXT"
    },
  }
}
