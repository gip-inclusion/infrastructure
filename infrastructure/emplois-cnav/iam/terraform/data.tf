data "scaleway_account_project" "emplois_cnav" {
  name     = "emplois-cnav"
  provider = scaleway.tmp
}

data "scaleway_iam_user" "kubernetes_users" {
  count = length(local.kubernetes_users_emails)
  email = local.kubernetes_users_emails[count.index]
}

data "sops_file" "secrets" {
  source_file = "secrets.enc.yaml"
}
