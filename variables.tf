variable "region" {
  description = "Región de AWS para el despliegue."
  type        = string
  default     = "us-east-1"
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "Formato de región AWS inválido (ej. us-east-1)."
  }
}

variable "proyecto" {
  description = "Nombre base del proyecto para prefijos."
  type        = string
  default     = "ep2-iac"
}

variable "environment" {
  description = "Entorno de ejecución (dev o prod)."
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "El entorno debe ser 'dev' o 'prod'."
  }
}

variable "owner" {
  description = "Propietario / estudiante a cargo."
  type        = string
  default     = "Jose Antonio Villarroel"
}

variable "asignatura" {
  description = "Asignatura correspondiente."
  type        = string
  default     = "AUY1103 - Infraestructura como Codigo I"
}

variable "estudiante_nombre" {
  description = "Nombre a mostrar en la página estática."
  type        = string
  default     = "Jose Antonio Villarroel"
}

variable "vpc_cidr" {
  description = "Bloque CIDR de la VPC."
  type        = string
  default     = "10.20.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "Debe ser un bloque CIDR IPv4 válido."
  }
}

variable "instance_type" {
  description = "Tipo de instancia EC2 (Learner Lab compatible)."
  type        = string
  default     = "t3.micro"
  validation {
    condition     = can(regex("^t[23]\\.(micro|small|medium)$", var.instance_type))
    error_message = "Permitido: t2/t3 micro, small o medium."
  }
}

variable "backend_count" {
  description = "Cantidad de servidores backend Docker."
  type        = number
  default     = 3
  validation {
    condition     = var.backend_count >= 1 && var.backend_count <= 5
    error_message = "backend_count debe ser entre 1 y 5."
  }
}

variable "db_username" {
  description = "Usuario maestro de RDS."
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_name" {
  description = "Nombre inicial de la base de datos."
  type        = string
  default     = "portal_db"
}
