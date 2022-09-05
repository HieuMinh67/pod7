provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.29.0"

  cluster_name    = "${var.namespace}-eks"
  cluster_version = "1.24"

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

}