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

**Please note, the s3 Backend expects the bucket where you want to store the state to exists beforehand**

If during development of the terraform config, you have to switch from an initial local backend to the S3 one and want to manage the creationg of the s3 bucket using the same config you can do the following: 

* Create the `aws_s3_bucket.terraform_state` resource in the config, apply the plan and get the bucket created
* You can now add the configuration for the s3 backend that will use the exising bucket

At this point the s3 bucket you defined as resource is loaded in the **state** and if you create a new **workspace** terraform will try to add it back. To avoid this you will better remove it from the state using the `terraform state rm` command or create the bucket from the `aws console` at the beginning.


*S3 Backend* also supports state *locking and consistency checking* via Dynamo DB that need to be configured yet.

## Workflow

One of the greatest benefits of *Infrastructure As Code* is that Infrastructure changes deployments can be autometed. 

Hashicorp provides a nice [GitHub Actions workflow](https://www.terraform.io/docs/github-actions/setup-terraform.html#github-actions-workflow-yaml) that has been setup already for this demo. 

* On a GitHub pull_request event, the workflow will checkout the GitHub repository, download Terraform CLI, configure the Terraform CLI configuration file with a Terraform Cloud user API token, and execute terraform init, terraform fmt -check and terraform plan.

* On a GitHub push event to the master branch, the workflow will perform the same actions as on a pull_request and will additionally execute terraform apply -auto-approve.

## Environments


Directly from the [Workspaces section](https://www.terraform.io/docs/state/workspaces.html) of Terraform documentation:

>Each Terraform configuration has an associated backend that defines how operations are executed and where persistent data such as the Terraform state are stored.

>The persistent data stored in the backend belongs to a workspace. Initially the backend has only one workspace, called "default", and thus there is only one Terraform state associated with that configuration.

>Certain backends support multiple named workspaces, allowing multiple states to be associated with a single configuration. The configuration still has only one backend, but multiple distinct instances of that configuration to be deployed without configuring a new backend or changing authentication credentials.

**Workspaces** are ideals to manage different states of the same infrastructure, so they are suitable to:

* Deploy and mantain replicas of the same infrastructure 
* Test infrastructure changes before going live

Since we are exploring migrating existing infrastructure to Terraform I envision two distict scenarios: 

* You infrastructure has already deployed replicas (environments) of the same configuration 
* You want to create new environments from a single instance of your configuration

In the first case you start with one replica, build the configuration as described above, then create a new workspace for every existing environment while tuning the configuration to match each environment and also import all the exising resources on the corresponding workspace.

In the second case, that is the simplest, you start with building the configuration for your single instance, then make the needed changes to it to allow multiples states, create the the new workspaces and create then resulting resources from there.

## Shared Resources

TODO








