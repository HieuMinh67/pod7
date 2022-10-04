# Re-produce Pod7
## 1.	Setup Cloud9
- Clone [repository](https://github.com/HieuMinh67/pod7) to local machine
- Copy AWS access key and secret key from sandbox to _(.auto).tfvars_ file in cloud9 folder (for example: _cloud9/aws_keys.auto.tfvars_) 
- Terraform init and apply
## 2.	Build infrastructure
- Login to AWS console and access to URL generate after Terraform apply
- Run commands in _cloud9/setup.sh_
- Copy AWS access key and secret key from sandbox to (.auto).tfvars file in terraform folder (for example: terraform/aws_keys.auto.tfvars) 
- Terraform apply
## 3.	Bastion host
- Connect to bastion host through SSH using the URL output from step 2 \
`ssh ec2-user@<load-balancer-url-from-output> -i private-key-bastion.pem`