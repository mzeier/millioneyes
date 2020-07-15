module "us-west-2" {
  source = "./millioneyes"
  region = "us-west-2"
}

output "us-west-2-eip" {
  value = module.us-west-2.public-ip
}

module "us-east-2" {
  source = "./millioneyes"
  region = "us-east-2"
}

output "us-east-2-eip" {
  value = module.us-east-2.public-ip
}

#module "eu-west-1" {
#  source = "./millioneyes"
#  region = "eu-west-1"
#}

#output "eu-west-1-eip" {
#  value = module.eu-west-1.public-ip
#}
