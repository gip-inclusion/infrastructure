terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.55.0"
    }
  }
  required_version = ">= 1.10"
}

# Users allowed to access the project during its early development phase.
resource "scaleway_iam_group" "secu_analyse_repo_admins" {
  name            = "secu-analyse-repo-admins"
  description     = var.managed
  organization_id = data.scaleway_account_project.secu_analyse_repo.organization_id
  user_ids = [
    "290c6ad8-f97c-464a-aeaf-ff43fb9a0e9d",
    "9d9a2605-a337-42ef-93d8-6333209b68f5",
    "e38f45cf-3c32-403d-8aa3-343202bcd815",
  ]
}

resource "scaleway_iam_policy" "policy" {
  name        = "secu-analyse-repo-admins"
  description = var.managed
  group_id    = scaleway_iam_group.secu_analyse_repo_admins.id
  rule {
    project_ids = [data.scaleway_account_project.secu_analyse_repo.project_id]
    permission_set_names = [
      "AllProductsFullAccess"
    ]
  }
}
