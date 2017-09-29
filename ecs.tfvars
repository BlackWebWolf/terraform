vpc_cidr = "10.0.0.0/16"

environment = "dev-stage"
cluster = "main"
public_subnet_cidrs = ["10.0.0.0/24", "10.0.1.0/24"]

private_subnet_cidrs = ["10.0.50.0/24", "10.0.51.0/24"]

availibility_zones = ["eu-central-1a", "eu-central-1b"]

max_size = 2

min_size = 2

desired_capacity = 2

instance_type = "t2.micro"


ecs_aws_ami = "ami-0460cb6b"
# ecs_config = "echo 'ECS_CLUSTER=main ' > /etc/ecs/ecs.config"
target_group_names = {
    "0" = "test", 
    "1" = "test1"
  }

target_groups_count = 2