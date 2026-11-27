locals {
  secu_analyse_repo_admins_for_policy = formatlist("user_id:%s", data.scaleway_iam_group.secu_analyse_repo_admins.user_ids)
}
