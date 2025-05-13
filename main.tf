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
  zone_name       = ""
  records = {
    "brevo-code-9672" = {
      name = ""
      data = "brevo-code:96720ae72c4b9e35f0b138dac0f441c4"
      type = "TXT"
    },
    "brevo-code-2d8d" = {
      name = ""
      data = "brevo-code:2d8d9f5f1d2fb27858f79eacaf64817d"
      type = "TXT"
    },
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
    "dmarc" = {
      name = "_dmarc"
      data = "v=DMARC1; p=quarantine; rua=mailto:98224b9a@in.mailhardener.com,mailto:dmarc@inclusion.gouv.fr,mailto:rua@dmarc.brevo.com!10m; fo=1"
      type = "TXT"
    },
    "etudes" = {
      name = "etudes"
      data = "cname.tally.so."
      type = "CNAME"
      ttl  = 10800
    },
    "google-dkim" = {
      name = "google._domainkey"
      data = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtYhB99qk0vLYpSd+nHCkR0TLE1K2v2OdQQb6NUso2aAhUiimuOOQ06EDapnhK4IGSEXISTW3fTXBECEGmeyQ6mZKsElS24k/O+0Q33ANvBCJf+4bkm7A7/ITj2rsbRZYRJXpjdrfD/wvc+FUf6h9gIE9/h1PNeA0vaTSBJnsqNX7bszw9W+8WMzf/vLm6Wii+76GhCZvVtN8s/4EZz5hW+TcbsHAouTcOuuUxx+wfkgEkkycBHuYjw9vszyNt/PBMxmKQXnrx8QxODZ03sc/CnQBDwc/JT7heWiFqbVSdN8VE0y42CFFuDa+JBNXFGv/qzLfePISppswEwn9AixlPwIDAQAB"
      type = "TXT"
      ttl  = 300
    },
    "google-mx-main" = {
      name     = ""
      data     = "aspmx.l.google.com."
      type     = "MX"
      priority = 1
    },
    "google-mx-alt1" = {
      name     = ""
      data     = "alt1.aspmx.l.google.com."
      type     = "MX"
      priority = 5
    },
    "google-mx-alt2" = {
      name     = ""
      data     = "alt2.aspmx.l.google.com."
      type     = "MX"
      priority = 5
    },
    "google-mx-alt3" = {
      name     = ""
      data     = "alt3.aspmx.l.google.com."
      type     = "MX"
      priority = 10
    },
    "google-mx-alt4" = {
      name     = ""
      data     = "alt4.aspmx.l.google.com."
      type     = "MX"
      priority = 10
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
    "mail-dkim" = {
      name = "mail._domainkey"
      data = "k=rsa;p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDeMVIzrCa3T14JsNY0IRv5/2V1/v2itlviLQBwXsa7shBD6TrBkswsFUToPyMRWC9tbR/5ey0nRBH0ZVxp+lsmTxid2Y2z+FApQ6ra2VsXfbJP3HE6wAO0YTVEJt1TmeczhEd2Jiz/fcabIISgXEdSpTYJhb0ct0VJRxcg4c8c7wIDAQAB"
      type = "TXT"
      ttl  = 10800
    },
    "mta-sts-txt" = {
      name = "_mta-sts"
      data = "v=STSv1; id=20250314T120200"
      type = "TXT"
      ttl  = 10800
    },
    "mta-sts-site" = {
      name = "mta-sts"
      data = "inclusion.gouv.fr."
      type = "CNAME"
    },
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
    "smtp.tls" = {
      name = "_smtp._tls"
      data = "v=TLSRPTv1; rua=mailto:98224b9a@in.mailhardener.com"
      type = "TXT"
    },
    "spf" = {
      name = ""
      data = "v=spf1 include:bnc3.mailjet.com include:spf.brevo.com include:_spf.google.com include:mail.zendesk.com ~all"
      type = "TXT"
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

module "dns-emplois" {
  source = "./dns"

  providers = { scaleway = scaleway.terraform_ci }

  organization_id = var.scw_organization_id
  managed         = local.managed
  zone_name       = "emplois"
  records = {
    "emplois-root" = {
      name = ""
      data = "domain.par.clever-cloud.com."
      type = "ALIAS"
    }
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
