variable "scalingo_api_token" {
  type        = string
  description = "Scalingo API token to manage the application"
  sensitive   = true
  ephemeral   = true
}
