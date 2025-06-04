module "bootstrap" {
  source = "./bootstrap"

  providers       = { scaleway = scaleway.terraform_ci }
  organization_id = var.scw_organization_id

  managed = local.managed
}

module "dns-root" {
  source = "./dns"

  providers = { scaleway = scaleway.terraform_ci }

  organization_id = var.scw_organization_id
  managed         = local.managed
  records = {
    "ciso" = {
      name = "ciso"
      data = "51.15.213.160"
      type = "A"
    },
    "cle-nir" = {
      name = "cle-nir"
      data = "calculette-nir-production.osc-fr1.scalingo.io."
      type = "CNAME"
    },
    "etudes" = {
      name = "etudes"
      data = "cname.tally.so."
      type = "CNAME"
      ttl  = 10800
    },
    "google-site-verification-YGht5" = {
      name = ""
      data = "google-site-verification=YGht5JTr0ujMA6cSZrZ9ysejKIn4ESV0v_ZQHL0hPqE"
      type = "TXT"
    },
    "google-workspace-key" = {
      name = "tpqsxaxytsb6"
      data = "gv-wnkxgmqxqqr3tm.dv.googlehosted.com."
      type = "CNAME"
      ttl  = 10800
    }
    "notion-dcv.pages" = {
      name = "_notion-dcv.pages"
      data = "1295f321-b604-81f8-8544-007038d42424"
      type = "TXT"
    },
    "ns0" = {
      name = ""
      data = "ns0.dom.scw.cloud."
      type = "NS"
      ttl  = 1800
    },
    "ns1" = {
      name = ""
      data = "ns1.dom.scw.cloud."
      type = "NS"
      ttl  = 1800
    },
    "pages" = {
      name = "pages"
      data = "external.notion.site."
      type = "CNAME"
    },
    "website1" = {
      name = ""
      data = "185.21.194.105"
      type = "A"
    },
    "website2" = {
      name = ""
      data = "80.247.12.255"
      type = "A"
    },
    "website3" = {
      name = ""
      data = "80.247.13.145"
      type = "A"
    },
    "website4" = {
      name = ""
      data = "148.253.96.193"
      type = "A"
    },
  }
}

output "ci_access_key" {
  value     = module.bootstrap.ci_access_key
  sensitive = true
}

output "ci_secret_key" {
  value     = module.bootstrap.ci_secret_key
  sensitive = true
}
