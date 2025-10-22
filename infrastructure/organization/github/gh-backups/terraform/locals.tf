locals {
  github_backups_api_key = jsondecode(
    base64decode(data.scaleway_secret_version.github_backups_api_key.data)
  )
}
