# note on tags: 
# https://engineering.deptagency.com/best-practices-for-terraform-aws-tags

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      owner   = "k8" #would be owning team
      project = "Electric Hydrogen Takehome"
    }
  }
}
