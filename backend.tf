terraform {
  backend "s3" {
    # sctp-ce9-tfstate s3 bucket has to be created first
    bucket = "sctp-ce9-tfstate" 
    # tfstate file is created by terraform after init
    key    = "joseph-ce9-module2-7.tfstate" # Replace the value of key to <your suggested name>.tfstate for example terraform-ex-ec2-<NAME>.tfstate
    region = "us-east-1"
  }
}