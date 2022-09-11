output "prod_db_pwd" {
  value = module.prod_db.db_config.password
  sensitive = true
}