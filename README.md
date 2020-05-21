# terraform-demo



This repo collects some material that will support the learning experience about importing an existing cloud infrastructure into terraform. 

The very fist step has been to simplify the problem so the existing infrastructure we start from is very minimal. It lives in AWS and is made of: 

* an S3 Bucket
* a CloudFront distribution that serves the S3 bucket content

Simplifying the infrastructure will allow us to focus on the process

## Setup 

Make sure to download and install terraform binary first (https://www.terraform.io/downloads.html) and then run 

`terraform init`

in the root of the project.



## Importing Resources

Terraform allows to import existing resources (https://www.terraform.io/docs/import/index.html). 
Resources from our sample infrastructure are already imported here but in general importing a resource works this way: 

* In the config file define the resource with and empty configuration

```
resource "aws_cloudfront_distribution" "cf" {

}
```

* On the command line run 

`terraform import aws_cloudfront_distribution.cf E3187LMRS3KU82`

Where `E3187LMRS3KU82` is the known ID of the resource, in this case a CloudFront Distribution. This operation will load the exising resource into the [state](https://www.terraform.io/docs/state/) and link the resource defined in the config file with the exising one so that the setup can be checked against the resource state.

* Fine tune the resource configuration until a `terraform plan` run will not detect any difference between the exising resource and its configuration. 

## Teamwork

While the default for the [state](https://www.terraform.io/docs/state/index.html) is to be stored locally it can be kept in a remote location allowing teamwork.

[Remote state](https://www.[]terraform.io/docs/state/remote.html) is a [backend](https://www.terraform.io/docs/backends/index.html) feature and we are using an [s3](https://www.terraform.io/docs/backends/types/s3.html) backend type here. 

*S3 Backend* also supports state *locking and consistency checking* via Dynamo DB that need to be configured yet.

## Workflow

One of the greatest benefits of *Infrastructure As Code* is that Infrastructure changes deployments can be autometed. 

Hashicorp provides a nice [GitHub Actions workflow](https://www.terraform.io/docs/github-actions/setup-terraform.html#github-actions-workflow-yaml) that has been setup already for this demo. 

* On a GitHub pull_request event, the workflow will checkout the GitHub repository, download Terraform CLI, configure the Terraform CLI configuration file with a Terraform Cloud user API token, and execute terraform init, terraform fmt -check and terraform plan.

* On a GitHub push event to the master branch, the workflow will perform the same actions as on a pull_request and will additionally execute terraform apply -auto-approve.

## Environments

TODO

## Shared Resources

TODO








