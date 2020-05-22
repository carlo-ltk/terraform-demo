/* 
resource "aws_s3_bucket" "terraform_state" {
    bucket = "yd-sample-terraform-state"
}
*/

terraform {
    backend "s3" {
        region  = "us-east-1"
        bucket  = "yd-sample-terraform-state"
        key     = "terraform.tfstate"
    }
}