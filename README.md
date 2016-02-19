# Deployment with Terraform in [cloud.ca](https://cloud.ca)
This deployment example will deploy :

* A VPC
* Two tiers, __web__ (load balancing enabled) and __data__ (standard).
* The __web__ tier will contain 3 load balanced instances
* The __data__ tier will contain 2 instances
* A public IP address will be acquired to load balance the instances in the web tier
* The __tfstate\.tf__ state file will be stored in [swift](http://docs.openstack.org/developer/swift/) to allow sharing within a team

## Usage

1. Install [Terraform](https://www.terraform.io/intro/getting-started/install.html)

2. Retrive your API keys for your cloud.ca compute and object-storage environments, and export them to environment variables

    ```
    export TF_VAR_api_key=YOUR_CS_API_KEY
    export TF_VAR_secret_key=YOUR_CS_SECRET_KEY
    export TF_VAR_project=YOUR_ENVIRONMENT_PROJECT_ID
    export OS_USERNAME=YOUR_SWIFT_USERNAME
    export OS_PASSWORD=YOUR_SWIFT_PASSWORD
    export OS_TENANT_NAME=YOUR_SWIFT_TENANT_NAME
    export OS_AUTH_URL=https://auth-east.cloud.ca/v2.0
   ```

3. Set terraform to use a container as remote backend. 

    ```
    terraform remote config -backend=swift -backend-config="path=private"
    ```

    By default, __backend_container__ variable is set to private. If you would like to use a different container, be sure to change it in the __variables.tf__ file and modify the command above.

4. Retrieve plan to deploy infrastructure

    ```
    terraform plan
    ```

5. Deploy your infrastructure

    ```
    terraform apply
    ```