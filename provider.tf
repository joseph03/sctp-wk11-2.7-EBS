# file: provider.tf from slide 19
/* not strictly required
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.83.1"
    }
  }
}
*/
provider "aws" {
  region = "us-east-1"
}
