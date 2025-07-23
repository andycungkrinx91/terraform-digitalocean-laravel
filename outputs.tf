output "webserver_public_ip" {
  description = "The public IP address of the Laravel web server."
  value       = module.webserver.public_ip
}

output "database_private_ip" {
  description = "The private IP address of the Percona database server."
  value       = module.database.private_ip
}

output "deployment_summary" {
  description = "A summary of the deployment with access details and next steps."
  depends_on = [
    null_resource.webserver_provisioner_wait,
    null_resource.database_provisioner_wait
  ]
  value = <<-EOT

  ========================================================================
  ✅ Your Laravel application has been successfully deployed!
  ========================================================================

  Application URL:
    http://${module.webserver.public_ip}

  Access Your Servers:
    - Web Server SSH:   ssh -i ${var.ssh_private_key_path} root@${module.webserver.public_ip}
    - Database SSH:     ssh -i ${var.ssh_private_key_path} root@${module.database.public_ip}

  Database Connection Details (from web server):
    - DB Host:          ${module.database.private_ip}
    - DB Name:          ${var.db_name}
    - DB User:          ${var.db_user}

  Key Server Paths:
    - Laravel Root:     /var/www/laravel
    - Nginx Config:     /etc/nginx/sites-available/laravel
    - MySQL Config:     /etc/mysql/percona-server.conf.d/
    - MySQL Data Dir:   ${var.database_disk_mount_path}

  ========================================================================
  EOT
}