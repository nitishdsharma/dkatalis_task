variable "AWS_REGION" {
  default = "us-west-2"
}

variable "AMIS" {
  type = map(string)
  default = {
    us-west-2 = "ami-0a634ae95e11c6f91"
  }
}

variable "key_name" {
  description = "key name - created separately and must exist in AWS account"
  default = "mykeypair"
}

provider "aws" {
  region = var.AWS_REGION
}
