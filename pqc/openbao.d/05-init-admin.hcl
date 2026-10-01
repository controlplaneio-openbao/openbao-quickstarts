initialize "admin" {
  request "policy" {
    operation = "create"
    path      = "sys/policy/admin"
    data = {
      policy = <<-EOT
        path "*" {
          capabilities = ["create", "read", "update", "delete", "list", "sudo"]
        }
      EOT
    }
  }

  request "userpass" {
    operation = "create"
    path      = "sys/auth/userpass"
    data = {
      type = "userpass"
    }
  }

  request "user" {
    operation = "create"
    path      = "auth/userpass/users/admin"
    data = {
      password = {
        eval_source     = "env"
        eval_type       = "string"
        env_var         = "DEMO_ADMIN_PASSWORD"
        require_present = true
      }
      token_policies = "default,admin"
    }
  }
}
