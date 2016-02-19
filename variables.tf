# Environment setup variables
variable "api_url" {
    default = "https://compute-east.cloud.ca/client/api"
}
variable "api_key" {}
variable "secret_key" {}
variable "project" {}

# Remote state
variable "backend_container" {
   default="private"
}

#Resource variables
variable "db_instance_count" {
   default = 2
}
variable "app_instance_count" {
   default = 3
}

#Resource defaults
variable "zone" {
    default = "QC-1"
}
variable "template" {
   default = "Ubuntu 14.04.4 HVM base (64bit)"
}
variable "allow_all_acl" {
   default = "9ba3ec65-2e1d-11e4-8e05-42a29a39fc92"
}
variable "service_offering" {
   default = "1vCPU.2GB"
}