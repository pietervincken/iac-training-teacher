variable "name" {
  type        = string
  description = "name of the YPP"
}

variable "location" {
  type        = string
  default     = "West Europe"
  description = "Region to put all of the resources in"
}

variable "common_tags" {
  type        = map(any)
  description = "map of all tags for the resources"
}

variable "email" {
  type        = string
  description = "email of trainee"
}

variable "aks_id" {
  type        = string
  description = "Used to assign YP rights to aks cluster"
}
