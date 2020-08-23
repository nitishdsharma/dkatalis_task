# Internet VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "main"
  }
}

# Subnets
resource "aws_subnet" "main-public-1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-west-2a"

  tags = {
    Name = "main-public-1"
  }
}


# Internet GW
resource "aws_internet_gateway" "main-gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

# route tables
resource "aws_route_table" "main-public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-gw.id
  }

  tags = {
    Name = "main-public-1"
  }
}

# route associations public
resource "aws_route_table_association" "main-public-1-a" {
  subnet_id      = aws_subnet.main-public-1.id
  route_table_id = aws_route_table.main-public.id
}

resource "aws_security_group" "access-Elasticsearch" {
  vpc_id      = aws_vpc.main.id
  name        = "allow-ssh-9200"
  description = "security group that allows ssh, access on port 9200 and all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow-access-to-elastic"
  }
}
resource "aws_instance" "example" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = "t2.xlarge"
  count = 1

  # the VPC subnet
  subnet_id = aws_subnet.main-public-1.id

  # the security group
  vpc_security_group_ids = [aws_security_group.access-Elasticsearch.id]

  # the public SSH key
  key_name = var.key_name

  associate_public_ip_address = true
  source_dest_check      = false
  private_ip            = "10.0.1.10"

  tags = {
	Name = "dkt-instance.${count.index}"
	}
}

resource "local_file" "boo" {
	content = "[all]\n${aws_instance.example.*.public_ip[0]}\n[all:vars]\nansible_ssh_user=ubuntu\nansible_ssh_private_key_file=mykeypair.pem"
	filename = "inventory"
}

resource "null_resource" "boo2" {
	provisioner "local-exec" {
		command = "yes | cp inventory ../configuration/inventory"
	}
	depends_on = [local_file.boo]
}
