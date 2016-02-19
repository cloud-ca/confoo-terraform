# Working demo file to deploy a VPC,
# 2 tiers, 3 application instances,
# 2 db instances and load balance the 3 application instances

#Store remote state in swift
resource "terraform_remote_state" "tf_state" {
    backend = "swift"
    config {
        path = "${var.backend_container}"
    }
}

# VPC for demo
resource "cloudstack_vpc" "demo" {
    name = "demo"
    cidr = "10.160.0.0/22"
    vpc_offering = "Default VPC offering"
    zone = "${var.zone}"
    project = "${var.project}"

}

# Tier for web application
resource "cloudstack_network" "web" {
    name = "web"
    cidr = "10.160.1.0/24"
    network_offering = "Load Balanced Tier"
    vpc = "${cloudstack_vpc.demo.id}"
    zone = "${var.zone}"
    aclid = "${var.allow_all_acl}"
    project = "${var.project}"
    depends_on = ["cloudstack_vpc.demo"]
}

# Tier for dbs
resource "cloudstack_network" "data" {
    name = "data"
    cidr = "10.160.2.0/24"
    network_offering = "Standard Tier"
    vpc = "${cloudstack_vpc.demo.id}"
    zone = "${var.zone}"
    aclid = "${var.allow_all_acl}"
    project = "${var.project}"
    depends_on = ["cloudstack_vpc.demo"]
}

# Db
resource "cloudstack_instance" "db" {
    name = "db${count.index}"
    service_offering= "${var.service_offering}"
    network = "${cloudstack_network.data.id}"
    template = "${var.template}"
    zone = "${var.zone}"
    keypair = "pdube"
    project = "${var.project}"
    count = "${var.db_instance_count}"
}

resource "template_file" "app_init" {
  count    = "${var.app_instance_count}"
  template = "${file("app.init")}"
  vars {
    instance_name = "app${count.index}"
  }
}

# Applications
resource "cloudstack_instance" "app" {
    name = "app${count.index}"
    service_offering= "${var.service_offering}"
    network = "${cloudstack_network.web.id}"
    template = "${var.template}"
    zone = "${var.zone}"
    project = "${var.project}"
    keypair = "pdube"
    count = "${var.app_instance_count}"
    user_data = "${element(template_file.app_init.*.rendered, count.index)}"
    depends_on = ["cloudstack_instance.db"]
}

# Acquire IP for load balancing web app
resource "cloudstack_ipaddress" "lb-ip" {
    vpc = "${cloudstack_vpc.demo.id}"
    project = "${var.project}"
}

# Acquire IP for load balancing web app
resource "cloudstack_ipaddress" "ssh-ip" {
    vpc = "${cloudstack_vpc.demo.id}"
    project = "${var.project}"
}

# Load balancer rule for web application
resource "cloudstack_loadbalancer_rule" "default" {
  name = "app-lb"
  description = "App load balancer rule"
  ipaddress = "${cloudstack_ipaddress.lb-ip.id}"
  algorithm = "roundrobin"
  network = "${cloudstack_network.web.id}"
  private_port = 5000
  public_port = 5000
  members = ["${cloudstack_instance.app.*.id}"]
  depends_on = ["cloudstack_instance.app"]
}

resource "cloudstack_port_forward" "ssh-pf" {
  ipaddress = "${cloudstack_ipaddress.ssh-ip.id}"
  forward {
    protocol = "tcp"
    private_port = 22
    public_port = 22
    virtual_machine = "${cloudstack_instance.app.0.id}"
  }
}

output "lb-ip" {
    value = "${cloudstack_ipaddress.lb-ip.ipaddress}"
}

output "ssh-ip" {
    value = "${cloudstack_ipaddress.ssh-ip.ipaddress}"
}