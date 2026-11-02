provider "aws" {
  region = "us-east-1"
}

module "network" {
  source     = "../../modules/network"
  cidr_block = "10.0.0.0/16"
}

resource "random_pet" "name" {}
