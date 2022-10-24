#output "prod_db_pwd" {
#  value     = module.prod_db.db_config.password
#  sensitive = true
#}

#output "kube_config" {
#  value = local.kubeconfig
#}

output "elb_dns" {
  value = module.bastion_host.elb_dns
}

output "access_vpc_url" {
  value = module.openvpn.access_vpn_url
}