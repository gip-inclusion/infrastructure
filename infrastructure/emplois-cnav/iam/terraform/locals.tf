locals {
  kubernetes_users_emails = yamldecode(data.sops_file.secrets.raw)["kubernetes_users_emails"]
}
