# Environment setup variables
variable "api_url" {
    default = "https://compute-east.cloud.ca/client/api"
}
variable "api_key" {}
variable "secret_key" {}
variable "project" {
    default = "1e749146-d81b-49e5-8df5-3052868a738c" 
}
variable "backend_container" {
   default="private"
}

#Resource variables
variable "zone" {
    default = "QC-1"
}
variable "template" {
   default = "Ubuntu 14.04.2 HVM base (64bit)"
}
variable "allow_all_acl" {
   default = "9ba3ec65-2e1d-11e4-8e05-42a29a39fc92"
}
variable "service_offering" {
   default = "1vCPU.2GB"
}
