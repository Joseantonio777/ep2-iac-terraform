output "region" {
  description = "Region de AWS utilizada en el despliegue."
  value       = data.aws_region.actual.region
}

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

output "cloudfront_url" {
  description = "URL publica de la distribucion CloudFront."
  value       = var.habilitar_cdn ? "https://${aws_cloudfront_distribution.cdn[0].domain_name}" : "CDN deshabilitado (variante aplicada)"
}

output "cdn_imagen_prueba_url" {
  description = "URL publica para acceder a la imagen de prueba via CloudFront."
  value       = var.habilitar_cdn ? "https://${aws_cloudfront_distribution.cdn[0].domain_name}/prueba-cdn.png" : "CDN deshabilitado (variante aplicada)"
}

output "bucket_imagenes" {
  description = "Nombre del bucket S3 privado que almacena los assets."
  value       = var.habilitar_cdn ? aws_s3_bucket.cdn[0].id : "CDN deshabilitado (variante aplicada)"
}
