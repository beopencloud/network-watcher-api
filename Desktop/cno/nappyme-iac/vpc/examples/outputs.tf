output "azs" {
  description = " A list of the Availability Zone names available to the account"
  value = data.aws_availability_zones.available.names
}