scw_region = "fr-par"
scw_zone   = "fr-par-1"

authentik_database_credentials_version = 1

api_relay_environments = ["integration", "production", "pentest"]

api_relay_django_secret_key_versions = {
  integration = 1
  production  = 1
  pentest     = 1
}

api_relay_database_credentials_versions = {
  integration = 1
  production  = 1
  pentest     = 1
}

api_relay_api_token_versions = {
  integration = 1
  production  = 1
  pentest     = 1
}
