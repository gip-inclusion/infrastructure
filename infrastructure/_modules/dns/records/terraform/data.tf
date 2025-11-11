data "scaleway_domain_zone" "zone" {
  domain     = "inclusion.gouv.fr"
  subdomain  = ""
  project_id = var.scw_project_id
}
