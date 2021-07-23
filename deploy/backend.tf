terraform {
  backend "gcs" {}
}

data "terraform_remote_state" "state" {
  backend = "gcs"
  config {
    bucket = var.tf_state_bucket
    prefix = "env/prod"
  }
}
