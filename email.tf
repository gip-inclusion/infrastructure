module "dns-mail" {
  source = "./dns"

  providers = { scaleway = scaleway.terraform_ci }

  organization_id = var.scw_organization_id
  managed         = local.managed
  records = {
    # Umbrella Brevo organization, root of all Brevo sub-projects.
    "brevo-code-2d8d" = {
      name = ""
      data = "brevo-code:2d8d9f5f1d2fb27858f79eacaf64817d"
      type = "TXT"
    },
    "dmarc" = {
      name = "_dmarc"
      data = "v=DMARC1; p=quarantine; rua=mailto:98224b9a@in.mailhardener.com,mailto:dmarc@inclusion.gouv.fr,mailto:rua@dmarc.brevo.com!10m; fo=1"
      type = "TXT"
    },
    "google-dkim" = {
      name = "google._domainkey"
      data = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtYhB99qk0vLYpSd+nHCkR0TLE1K2v2OdQQb6NUso2aAhUiimuOOQ06EDapnhK4IGSEXISTW3fTXBECEGmeyQ6mZKsElS24k/O+0Q33ANvBCJf+4bkm7A7/ITj2rsbRZYRJXpjdrfD/wvc+FUf6h9gIE9/h1PNeA0vaTSBJnsqNX7bszw9W+8WMzf/vLm6Wii+76GhCZvVtN8s/4EZz5hW+TcbsHAouTcOuuUxx+wfkgEkkycBHuYjw9vszyNt/PBMxmKQXnrx8QxODZ03sc/CnQBDwc/JT7heWiFqbVSdN8VE0y42CFFuDa+JBNXFGv/qzLfePISppswEwn9AixlPwIDAQAB"
      type = "TXT"
      ttl  = 300
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
    "google-mx-main" = {
      name     = ""
      data     = "aspmx.l.google.com."
      type     = "MX"
      priority = 1
    },
    "mail-dkim" = {
      name = "mail._domainkey"
      data = "k=rsa;p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDeMVIzrCa3T14JsNY0IRv5/2V1/v2itlviLQBwXsa7shBD6TrBkswsFUToPyMRWC9tbR/5ey0nRBH0ZVxp+lsmTxid2Y2z+FApQ6ra2VsXfbJP3HE6wAO0YTVEJt1TmeczhEd2Jiz/fcabIISgXEdSpTYJhb0ct0VJRxcg4c8c7wIDAQAB"
      type = "TXT"
      ttl  = 10800
    },
    "mta-sts-site" = {
      name = "mta-sts"
      data = "inclusion.gouv.fr."
      type = "CNAME"
    },
    "mta-sts-txt" = {
      name = "_mta-sts"
      data = "v=STSv1; id=20250314T120200"
      type = "TXT"
      ttl  = 10800
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
  }
}
