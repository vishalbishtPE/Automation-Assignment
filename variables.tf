variable "create" {
  default     = true
  description = "create is the variable used in all resources to conditionally create them"
}

variable "ecs_cluster_id" {
  description = "The cluster to which the ECS Service will be added"
}



variable "aws_region" {
  description = "Region for the VPC"
  default = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the private subnet"
  default = "10.0.2.0/24"
}


variable "private_subnet_cidr2" {
  description = "CIDR for the private subnet"
  default = "10.0.3.0/24"
}


variable "private_subnet_cidr3" {
  description = "CIDR for the private subnet"
  default = "10.0.4.0/24"
}


variable "ami" {
  description = "Amazon Linux AMI"
  default = "ami-4fffc834"
}

variable "key_path" {
  description = "SSH Public Key path"
  default = "/home/vishal/vishal-keypair.pem"
}

variable "database_name" {
  description = "Name of the Database"
  default = "mydb-vishal"
}

variable "database_user" {
  description = "Database user name"
  default = "vishal-user"
}

variable "database_password" {
  description = "Database password, same as username"
  default = "vishal-user"
}
