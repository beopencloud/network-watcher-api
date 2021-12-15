
output "nappyme_vpc" {
  description   = "vpc network configuration"
  value         = aws_vpc.nappyme_vpc
}
output "private_subnet_eks_1" {
  description   = "private subnet on az eu_west_1a"
  value         = aws_subnet.private_subnet_eks_1
}

output "private_subnet_eks_2" {
  description   = "private subnet on az eu_west_1b"
  value         = aws_subnet.private_subnet_eks_1
}



