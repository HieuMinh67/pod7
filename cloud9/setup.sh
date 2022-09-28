git clone https://github.com/HieuMinh67/pod7
git clone https://github.com/aws-samples/terraform-eks-code.git tfekscode
cd tfekscode
source setup-tools.sh
cd ../pod7/terraform
terraform providers lock -platform=linux_amd64
terraform init
