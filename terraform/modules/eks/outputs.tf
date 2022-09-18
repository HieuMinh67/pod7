output "endpoint" {
  value = module.eks.cluster_endpoint
}

output "certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "name" {
  value = module.eks.cluster_id
}

output "sg_id" {
  value = module.eks.cluster_primary_security_group_id
}