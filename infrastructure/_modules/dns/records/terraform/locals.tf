locals {
  # Root zone defined statically since data provider has ambiguous ID
  root_zone = {
    id = "inclusion.gouv.fr"
  }
}
