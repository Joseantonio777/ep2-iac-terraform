locals {
  nombre_base = "${var.proyecto}-${var.environment}"

  tags_comunes = {
    Owner       = var.owner
    Environment = var.environment
    Project     = var.proyecto
    Asignatura  = var.asignatura
    ManagedBy   = "Terraform"
  }

  azs = slice(data.aws_availability_zones.disponibles.names, 0, 2)

  subredes_publicas = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 8, i)]
  subredes_bd       = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 8, i + 20)]

  albs = {
    estatico = { desc = "Sitio Estatico", health = "/" }
    backend  = { desc = "Backends Docker", health = "/" }
  }

  mi_ip_cidr = "${chomp(data.http.mi_ip.response_body)}/32"
}
