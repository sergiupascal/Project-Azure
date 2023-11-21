# Project-Azure
Team AZURE
Your Responsibility to break in to 3 teams, VPC, Autoscaling, Database
1. Chelsea Woods
2. Abdullo
3. Alexander Safronov
4. Sergiu Pascal
5. Tatiana Rotaru

Step1
Build terraform module for a Three-Tier application on Azure:
1 VNET
3 public subnets
This module should be able to create resource group. Once the VPC module is
ready, please release. Release the module on terraform registry.

Step2
On top of VPC from previous step, please create Linux Scale Set Linux Scale Set
should use minimum 1 instance. This Linux Scale Set should create its own
Traffic Manager that is accessible from the internet.

Step3
Create Azure MySQL to use with wordpress autoscaling group..