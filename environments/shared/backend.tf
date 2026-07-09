terraform {
  backend "gcs" {
    bucket = "freightfox-tfstate-shared"
    prefix = "terraform/state"
  }
}
