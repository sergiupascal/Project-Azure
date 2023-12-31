# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = true 
  features {}
}

# Configure the AWS account
provider "aws" {
  region     = "us-east-1"
  access_key = var.accesskey
  secret_key = var.secretkey
}

# AWS Route 53
resource "aws_route53_record" "projectwordpressdb" {
  zone_id = var.zoneid
  name    = "wordpress-${var.location}"
  type    = "A"
  ttl     = 300
  records = [azurerm_public_ip.project-public-ip.ip_address]
}
