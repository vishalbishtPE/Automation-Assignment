# Define our VPC
resource "aws_vpc" "vishal-default-vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true


  tags = {
    Name = "Pe-Project"
  }
}


#---------------------------------------------
#Define our subnet 
#Define the public subnet
resource "aws_subnet" "vishal-public-subnet" {
  vpc_id = "${aws_vpc.vishal-default-vpc.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Web Public Subnet"
  }
}



#----------------------------------------------
# Define the private subnet
resource "aws_subnet" "vishal-private-subnet" {
  vpc_id = "${aws_vpc.vishal-default-vpc.id}"
  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "us-east-1b"

  tags = {
    Name = "EC2 Instance Private Subnet"
  }
}


#----------------------------------------------
# Define the private subnet 2
resource "aws_subnet" "vishal-private-subnet2" {
  vpc_id = "${aws_vpc.vishal-default-vpc.id}"
  cidr_block = "${var.private_subnet_cidr2}"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Database Private Subnet"
  }
}


#----------------------------------------------
# Define the private subnet 3 for subnet group
resource "aws_subnet" "vishal-private-subnet3" {
  vpc_id = "${aws_vpc.vishal-default-vpc.id}"
  cidr_block = "${var.private_subnet_cidr3}"
  availability_zone = "us-east-1c"

  tags = {
    Name = "Database Private Subnet"
  }
}



#---------------------------------------------------
# Define the internet gateway
resource "aws_internet_gateway" "vishal-igw" {
  vpc_id = "${aws_vpc.vishal-default-vpc.id}"

  tags = {
    Name = "VPC IGW"
  }
}




#--------------------------------------------------------
# Nat gateway #1
resource "aws_eip" "nat_1" {
  vpc = true
}


resource "aws_nat_gateway" "nat_1" {
  allocation_id = "${aws_eip.nat_1.id}"
  subnet_id = "${aws_subnet.vishal-public-subnet.id}"
}




#----------------------------------------------------
# Define the route table for public
resource "aws_route_table" "vishal-web-public-rt" {
  vpc_id = "${aws_vpc.vishal-default-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vishal-igw.id}"
  }

  tags = {
    Name = "Public Subnet RT"
  }
}



#--------------------------------------------------------
# Define the route table for private subnet 
resource "aws_route_table" "vishal-web-private-rt" {
  vpc_id = "${aws_vpc.vishal-default-vpc.id}"

  route {
    #cidr_block is destination, gateway_id is source
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat_1.id}"
  }

  tags = {
    Name = "Public Subnet RT"
  }
}




#-----------------------------------------------------------
# Assign the route table to the public Subnet
resource "aws_route_table_association" "web-public-rt" {
  subnet_id = "${aws_subnet.vishal-public-subnet.id}"
  route_table_id = "${aws_route_table.vishal-web-public-rt.id}"
}


#----------------------------------------------------------
#Assign the route table to the private subnet
resource "aws_route_table_association2" "web-public-rt" {
  subnet_id = "${aws_subnet.vishal-private-subnet.id}"
  route_table_id = "${aws_route_table.vishal-web-private-rt.id}"
}


#----------------------------------------------------------
# Define the security group for public subnet
resource "aws_security_group" "sgweb" {
  name = "vpc_test_web"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }



  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }


  vpc_id="${aws_vpc.vishal-default-vpc.id}"

  tags = {
    Name = "Web Server SG"
  }
}



#----------------------------------------------------
# Define the security group for private subnet
resource "aws_security_group" "sgec2"{
  name = "sg_test_ec2"
  description = "Allow traffic from public subnet"

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  vpc_id = "${aws_vpc.vishal-default-vpc.id}"

  tags = {
    Name = "DB SG"
  }
}


#----------------------------------------------------------------
# Define the security group for private subnet
resource "aws_security_group" "sgdb"{
  name = "sg_test_db"
  description = "Allow traffic from private subnet 1"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["${var.private_subnet_cidr}"]
  }

  ingress {
    from_port = 3389
    to_port = 3389
    protocol = "icmp"
    cidr_blocks = ["${var.private_subnet_cidr}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.private_subnet_cidr}"]
  }

  vpc_id = "${aws_vpc.vishal-default-vpc.id}"

  tags = {
    Name = "DB SG"
  }
}


#--------------------------------------------------
# Define SSH key pair for our instances
resource "aws_key_pair" "vishal-default-keypair" {
  key_name = "vishal-keypair"
  public_key = "${file("${var.key_path}")}"
}



#---------------------------------------------------
# Define webserver inside the public subnet
resource "aws_instance" "wb-instance" {
   ami  = "${var.ami}"
   instance_type = "t2.micro"
   key_name = "${aws_key_pair.vishal-default-keypair.id}"
   subnet_id = "${aws_subnet.vishal-public-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.sgweb.id}"]
   associate_public_ip_address = true
   source_dest_check = false

  tags = {
    Name = "webserver"
  }
}




#---------------------------------------------------
# Define ec2 inside the private subnet
resource "aws_instance" "wb2-instance" {
   ami  = "${var.ami}"
   instance_type = "t2.micro"
   key_name = "${aws_key_pair.vishal-default-keypair.id}"
   subnet_id = "${aws_subnet.vishal-private-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.sgec2.id}"]
   associate_public_ip_address = false
   source_dest_check = false

  tags = {
    Name = "webserver"
  }
}


#---------------------------------------------------
# Define ec2 inside the private subnet
resource "aws_instance" "db" {
   ami  = "${var.ami}"
   instance_type = "t2.micro"
   key_name = "${aws_key_pair.vishal-default-keypair.id}"
   subnet_id = "${aws_subnet.vishal-private-subnet2.id}"
   vpc_security_group_ids = ["${aws_security_group.sgdb.id}"]
   associate_public_ip_address = false
   source_dest_check = false

  tags = {
    Name = "Database"
  }
}


#-----------------------------------------------------------
resource "aws_db_subnet_group" "default-db-subnet-group" {
  name       = "main"
  subnet_ids = ["${aws_subnet.vishal-private-subnet2.id}", "${aws_subnet.vishal-private-subnet3.id}"]

  tags = {
    Name = "My DB subnet group"
  }
}

#-----------------------------------------------------------

#---------------------------------------------------
resource "aws_db_instance" "vishal-db-instance" {
  allocated_storage         = 5
  engine                    = "mysql"
  engine_version            = "5.6.35"
  instance_class            = "db.t2.micro"
  name                      = "${var.database_name}"
  username                  = "${var.database_user}"
  password                  = "${var.database_password}"
  db_subnet_group_name      = "${aws_db_subnet_group.default-db-subnet-group.id}"
  vpc_security_group_ids    = ["${aws_security_group.sgdb.id}"]
  skip_final_snapshot       = true
  final_snapshot_identifier = "Ignore"
}



