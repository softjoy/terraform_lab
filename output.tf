output "rowvpc-id" {
  value = aws_vpc.vpc.id
}

//to print out public ip
output "instance_ip" {
  value = aws_instance.instance.public_ip
}