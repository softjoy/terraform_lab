#creating local name for my resources
locals {
  name = "row"
}
#creating pvc 
resource "aws_vpc" "vpc" {
  cidr_block       = var.cidr
  instance_tenancy = "default"

  tags = {
    Name = "$(locals.name)-vpc"
  }
}
//creating pub_subnet
resource "aws_subnet" "sub1" {
  availability_zone = "us-east-1a"
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr2

  tags = {
    Name = "$(locals.name)-sub1"
  }
}

#creating internet_gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "$(locals.name)-gw"
  }
}

#creating route_table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.allcidr
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "$(locals.name)-rt"
  }
}

#creating route_table_association 
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.rt.id
}

//creating security_group
resource "aws_security_group" "sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "$(locals.name)-sg"
  }
}

resource "aws_security_group_rule" "sgr1" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.allcidr]
  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "sgr2" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.allcidr]
  security_group_id = aws_security_group.sg.id
}

#creating keypair
resource "aws_key_pair" "key" {
  key_name   = "$(locals.name)-keypair"
  public_key = file("./rowkeypair.pub")
}

//creating instance
resource "aws_instance" "instance" {
  ami                         = "ami-0fe630eb857a6ec83" //redhat ami
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = aws_subnet.sub1.id
  associate_public_ip_address = true
  tags = {
    Name = "$(locals.name)-instance"
  }
}