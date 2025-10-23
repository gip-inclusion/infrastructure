data "scalingo_region" "secnum_cloud" {
  name     = "osc-secnum-fr1"
  provider = scalingo.tmp
}

data "scalingo_stack" "scalingo_24" {
  name = "scalingo-24"
}
