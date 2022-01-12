variable "project_id" {
  type = string
}
variable "location" {
  type = map(string)
  default = {
    "region" = "europe-central2"
    "zone"   = "europe-central2-a"
  }
  description = "is closest (Warsaw, Poland), supports E2 machine that is required"
}

variable "image_id" {
  type = string
}

variable "instance_count" {
  type = map(number)
  default = {
    "min" = 3
    "max" = 6
  }
}