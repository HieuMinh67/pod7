resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db_user" {
  name = "${var.namespace}-db-account"
}

resource "aws_secretsmanager_secret_version" "db_user_version" {
  secret_id     = aws_secretsmanager_secret.db_user.id
  secret_string = <<EOF
    {
      "username": "${var.namespace}_admin",
      "password": "${random_password.password.result}"
    }
  EOF
}