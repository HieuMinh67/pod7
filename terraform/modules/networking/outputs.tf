output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc" {
  value = module.vpc
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "sg" {
  value = {
    lb     = module.lb_sg.security_group.id
    db     = module.db_sg.security_group.id
    websvr = module.websvr_sg.security_group.id
  }
}
