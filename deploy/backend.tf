terraform {
  backend "gcs" {}
}

data "terraform_remote_state" "state" {
  backend = "gcs"
  config  = {
    bucket = var.bucket
    prefix = "env/prod"
  }
}
