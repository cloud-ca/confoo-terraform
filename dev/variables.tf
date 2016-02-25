#Required variables
variable "api_url" {
    default = "https://compute-east.cloud.ca/client/api"
}
variable "api_key" {}
variable "secret_key" {}
variable "project" {}
variable "backend_container" {}

#Required resource variables
variable "vpc_cidr" {}
variable "app_instance_count" {}
variable "db_instance_count" {}
variable "ssh_key" {}

#Resource defaults
variable "service_offering" {
   default = "1vCPU.2GB"
}
variable "template" {
   default = "Ubuntu 14.04.4 HVM base (64bit)"
}
variable "zone" {
    default = "QC-1"
}
variable "allow_all_acl" {
   default = "9ba3ec65-2e1d-11e4-8e05-42a29a39fc92"
}

#LB defaults
variable "lb_port" {
   default = 5000
}
variable "lb_algorithm"{
   default = "roundrobin"
}