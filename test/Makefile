# Chaining the commands
pull: 
	git pull

init: pull
	terraform init 

validate: init
	terraform validate 


eastus-plan: init
	terraform plan  -var-file envs/East-US/eastus.tfvars


centralus: init
	terraform workspace new  centralus  || terraform workspace select  centralus   &&  terraform apply --auto-approve  -var-file envs/Central-US/centralus.tfvars

canadacentral: init
	terraform workspace new  canadacentral  || terraform workspace select  canadacentral && terraform apply --auto-approve  -var-file envs/Canada-Central/canadacentral.tfvars

eastus: init
	terraform workspace new  eastus  || terraform workspace select  eastus  && terraform apply --auto-approve  -var-file envs/East-US/eastus.tfvars

eastasia: init
	terraform workspace new  eastasia  || terraform workspace select  eastasia && terraform apply --auto-approve  -var-file envs/East-Asia/eastasia.tfvars

northeurope: init
	terraform workspace new  northeurope  || terraform workspace select  northeurope && terraform apply --auto-approve  -var-file envs/North-Europe/northeurope.tfvars

uksouth: init
	terraform workspace new  uksouth  || terraform workspace select  uksouth && terraform apply --auto-approve  -var-file envs/UK-South/uksouth.tfvars

westus: init
	terraform workspace new  westus  || terraform workspace select  westus && terraform apply --auto-approve  -var-file envs/West-US/westus.tfvars


centralus-destroy: init
	terraform workspace new  centralus  || terraform workspace select  centralus && terraform destroy --auto-approve  -var-file envs/Central-US/centralus.tfvars

canadacentral-destroy: init
	terraform workspace new  canadacentral   || terraform workspace select  canadacentral  && terraform destroy --auto-approve  -var-file envs/Canada-Central/canadacentral.tfvars

eastus-destroy: init
	terraform workspace new  eastus  || terraform workspace select  eastus && terraform destroy --auto-approve  -var-file envs/East-US/eastus.tfvars

eastasia-destroy: init
	terraform workspace new  eastasia  || terraform workspace select  eastasia && terraform destroy --auto-approve  -var-file envs/East-Asia/eastasia.tfvars

northeurope-destroy: init
	terraform workspace new  northeurope  || terraform workspace select  northeurope && terraform destroy --auto-approve  -var-file envs/North-Europe/northeurope.tfvars

uksouth-destroy: init
	terraform workspace new  uksouth  || terraform workspace select  uksouth && terraform destroy --auto-approve  -var-file envs/UK-South/uksouth.tfvars

westus-destroy: init
	terraform workspace new  westus  || terraform workspace select  westus && terraform destroy --auto-approve  -var-file envs/West-US/westus.tfvars


cleanup:
	find / -type d  -name ".terraform" -exec rm -rf {} \; 

all:
	make canadacentral && make centralus && make eastus && make eastasia && make northeurope && make uksouth && make westus

destroy-all:
	make canadacentral-destroy && make centralus-destroy && make eastus-destroy && make eastasia-destroy && make northeurope-destroy && make uksouth-destroy && make westus-destroy