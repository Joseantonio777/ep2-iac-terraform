output "alb_estatico_dns" {
  description = "DNS del ALB para el sitio estatico."
  value       = "http://${aws_lb.this["estatico"].dns_name}"
}

output "alb_backend_dns" {
  description = "DNS del ALB para los backends Docker."
  value       = "http://${aws_lb.this["backend"].dns_name}"
}

output "rds_endpoint" {
  description = "Endpoint de conexion MySQL (DBeaver)."
  value       = aws_db_instance.mysql.address
}

output "rds_password" {
  description = "Contrasena generada para RDS MySQL (sensitive)."
  value       = random_password.db.result
  sensitive   = true
}

output "backend_instance_ids" {
  description = "IDs de las instancias EC2 del backend Docker."
  value       = module.servidor_backend.instance_ids
}
