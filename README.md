# tf-gce-image
## Deployment

### Deploying The Configuration

Define the region you want to test this out in:

```
gcloud config set compute/region us-east4
```

Then the configuration can be deployed by executing:

```
make create
```

This will:
1. Read your project & zone configuration to generate a couple config files:
  * `./terraform/terraform.tfvars` for Terraform variables
2. Run `terraform init` to prepare Terraform to create the infrastructure
3. Run `terraform apply` to actually create the infrastructure 

## Teardown

When you are finished with this example, and you are ready to clean up the resources that were created so that you avoid accruing charges, you can run the following command to remove all resources :

```
make teardown
```