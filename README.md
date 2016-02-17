# Deployment example in cloud.ca with Terraform
This deployment example will deploy a VPC with two tiers, web (load balancing enabled) and data (standard).

* The __web__ tier will contain 3 load balanced instances.
* The __data__ tier will contain 2 instances.

The Terraform state file (__tfstate\.tf__) will be stored in [swift](http://docs.openstack.org/developer/swift/) to allow sharing within a team.
## First steps
Install Terraform
```bash
terraform
```