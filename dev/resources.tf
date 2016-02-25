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
    cidr = "${var.vpc_cidr}"
    vpc_offering = "Default VPC offering"
    zone = "${var.zone}"
    project = "${var.project}"
}

# Tier for web application
resource "cloudstack_network" "web" {
    name = "web"
    cidr = "${cidrsubnet("${var.vpc_cidr}", 2, 1)}"
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
    cidr = "${cidrsubnet("${var.vpc_cidr}", 2, 2)}"
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
    keypair = "${var.ssh_key}"
    project = "${var.project}"
    count = "${var.db_instance_count}"
}

# Applications
resource "cloudstack_instance" "app" {
    name = "app${count.index}"
    service_offering= "${var.service_offering}"
    network = "${cloudstack_network.web.id}"
    template = "${var.template}"
    zone = "${var.zone}"
    project = "${var.project}"
    keypair = "${var.ssh_key}"
    count = "${var.app_instance_count}"
    user_data = "${element(template_file.app_init.*.rendered, count.index)}"
    depends_on = ["cloudstack_instance.db"]
}

resource "template_file" "app_init" {
  count    = "${var.app_instance_count}"
  template = "${file("app.init")}"
  vars {
    instance_name = "app${count.index}"
    app_port = "${var.lb_port}"
  }
}

# Acquire IP for load balancing web app
resource "cloudstack_ipaddress" "lb_ip" {
    vpc = "${cloudstack_vpc.demo.id}"
    project = "${var.project}"
}

# Load balancer rule for web application
resource "cloudstack_loadbalancer_rule" "app_lbr" {
  name = "app-lb"
  description = "App load balancer rule"
  ipaddress = "${cloudstack_ipaddress.lb_ip.id}"
  algorithm = "${var.lb_algorithm}"
  network = "${cloudstack_network.web.id}"
  private_port = "${var.lb_port}"
  public_port = "${var.lb_port}"
  members = ["${cloudstack_instance.app.*.id}"]
  depends_on = ["cloudstack_instance.app"]
}

output "lb_ip" {
    value = "${cloudstack_ipaddress.lb_ip.ipaddress}"
}

# Acquire IP for ssh
resource "cloudstack_ipaddress" "ssh_ip" {
    vpc = "${cloudstack_vpc.demo.id}"
    project = "${var.project}"
}

resource "cloudstack_port_forward" "ssh_pf" {
  ipaddress = "${cloudstack_ipaddress.ssh_ip.id}"
  forward {
    protocol = "tcp"
    private_port = 22
    public_port = 22
    virtual_machine = "${cloudstack_instance.app.0.id}"
  }
}

output "ssh_ip" {
    value = "${cloudstack_ipaddress.ssh_ip.ipaddress}"
}