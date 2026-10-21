output "security_group_id" {
  description = "ID del Security Group de las instancias."
  value       = aws_security_group.this.id
}

output "instance_ids" {
  description = "IDs de las instancias creadas."
  value       = aws_instance.this[*].id
}
