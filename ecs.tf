provider "aws" {
  region = "eu-central-1"
}

module "ecs" {
  source = "modules/ecs"

  environment          = "${var.environment}"
  cluster              = "${var.cluster}"
  cloudwatch_prefix    = "${var.environment}"           #See ecs_instances module when to set this and when not!
  vpc_cidr             = "${var.vpc_cidr}"
  public_subnet_cidrs  = "${var.public_subnet_cidrs}"
  private_subnet_cidrs = "${var.private_subnet_cidrs}"
  availibility_zones   = "${var.availibility_zones}"
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  desired_capacity     = "${var.desired_capacity}"
  key_name             = "${aws_key_pair.ecs.key_name}"
  instance_type        = "${var.instance_type}"
  ecs_aws_ami          = "${var.ecs_aws_ami}"
}
# module "users" {
#   source = "modules/users"
# }

resource "aws_key_pair" "ecs" {
  key_name   = "ecs-key-${var.environment}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDmgSGbbltEAUJxVMiA0rr5xU2k9Gwr/EeuZLurHfSwreIuWxmS8dl5ETVDj+00l17uMzGaq2f6k1YOeDfIuPIHoSF7rHIHjrTBIXfGNqWoD5kMXPkaiU8f6V4IroC1gyH8ZTUV5TJlzg9ekila+cGTeh3m1ODBzoxjJ+S4+nh338aIt98UEN5nevpF+G/Z1zuILsqnJ5p6M0MgkR5B6nuXE1iYk36xEnh1D/2TQ2LCDhRLfUbHJKn+bdF/nuACwcindT1R02PNWC6+yndpKBUt34oOGt+bZNnZ362/OOoU2DBYzQmVOSiokYIrrNwUQF3scbLQSatqg5ymF0+dZynf wilq@WilqHive"
}

variable "vpc_cidr" {}
variable "environment" {}
variable "max_size" {}
variable "min_size" {}
variable "desired_capacity" {}
variable "instance_type" {}
variable "ecs_aws_ami" {}
variable "cluster" {}

variable "private_subnet_cidrs" {
  type = "list"
}

variable "public_subnet_cidrs" {
  type = "list"
}

variable "availibility_zones" {
  type = "list"
}

output "default_alb_target_group" {
  value = "${module.ecs.default_alb_target_group}"
}
