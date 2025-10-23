variable "scalingo_api_token" {
  type        = string
  description = "API token to connect to Scalingo"
  ephemeral   = true
  sensitive   = true
}
