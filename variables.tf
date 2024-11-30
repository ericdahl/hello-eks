variable "admin_cidr" {}

variable "availability_zones" {
  default = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
  ]
}

variable "public_key" {}

variable "name" {
  default = "hello-eks"
}
