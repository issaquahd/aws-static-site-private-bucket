variable "region" {
  description = "Region for the private origin bucket"
  type        = string
  default     = "us-east-2"
}

variable "name_prefix" {
  description = "Prefix for the bucket name and the OAC name"
  type        = string
  default     = "static-site-demo"
}
