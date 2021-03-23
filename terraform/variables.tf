variable "tags" {
  type        = map(string)
  description = "(Optional) A mapping of tags to assign to the resource"
  default = {
    environment = "dev"
    application = "CRIB"
    deployment  = "terraform-local"
  }
}