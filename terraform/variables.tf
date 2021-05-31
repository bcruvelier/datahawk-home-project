variable "project" {
  type = string
  description = "Datahawk-Home-Project"
}

variable "environment" {
  type = string
  default = "__environment__"
  description = "Environment (dev / integration / production)"
}

variable "location" {
  type = string
  default = "__location__"
  description = "Azure region to deploy module to"
}

variable "account_replication_type" {
    type = map
    default = {
      dev = "LRS"
      Integration = "ZRS"
      Production = "ZRS"
    }
}