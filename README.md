# Pod7

![Pod7 drawio](https://user-images.githubusercontent.com/43398131/219548806-3f462296-a069-4550-9fcf-a134b28854d3.png)

## Project summary
As a participant in a project where only one member is tasked with practicing and learning how to use Terraform, AWS, and DevOps tools to deploy an application to production and development environments.

My primary focus in this project was becoming proficient in the use of Terraform, a powerful infrastructure as code tool used for building, changing, and versioning infrastructure. I will spend time learning the syntax, concepts, and best practices for creating infrastructure as code using Terraform. Additionally, I will become familiar with AWS services and how to configure and deploy resources using Terraform.

As I become more comfortable with Terraform and AWS, I will also work on understanding and utilizing various DevOps tools (ArgoCD, Helm, Github Actions, …) for application deployment and management. This will include learning about CI/CD pipelines, automated testing, monitoring, and logging tools. By implementing these DevOps practices, I will be able to ensure that the application is deployed and maintained in a reliable, efficient, and secure manner.

Throughout this project, I will work independently to research and implement best practices, troubleshoot issues, and develop a comprehensive understanding of Terraform, AWS, and DevOps tools. As the sole participant in this project, I will have the opportunity to experiment with different approaches and develop a deep understanding of the technology stack.

By the end of this project, I will have gained valuable experience in building and deploying infrastructure as code using Terraform, as well as working with AWS and DevOps tools to deploy and manage applications. These skills will be invaluable in my future work and will help me to become a more effective and efficient software developer.

## Setup Cloud9
- Clone [repository](https://github.com/HieuMinh67/pod7) to local machine
- Copy AWS access key and secret key from sandbox to _(.auto).tfvars_ file in cloud9 folder (for example: _cloud9/aws_keys.auto.tfvars_) 
- Terraform init and apply
## Build infrastructure
- Login to AWS console and access to URL generate after Terraform apply
- Run commands in _cloud9/setup.sh_
- Copy AWS access key and secret key from sandbox to (.auto).tfvars file in terraform folder (for example: terraform/aws_keys.auto.tfvars) 
- Terraform apply
## Appendix
- Connect to bastion host through SSH using the URL output from step 2 and private key automatically generated 
(saved in ) \
`ssh ec2-user@<load-balancer-url-from-output> -i private-key-bastion.pem`
