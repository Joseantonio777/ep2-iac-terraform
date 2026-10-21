variable "region" {
  description = "Region de AWS para el despliegue de infraestructura."
  type        = string
  default     = "us-east-1"
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "Formato de region AWS invalido (ej. us-east-1)."
  }
}

variable "proyecto" {
  description = "Nombre base del proyecto para prefijos de recursos."
  type        = string
  default     = "ep2-iac"
}

variable "environment" {
  description = "Entorno de ejecucion (dev o prod)."
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "El entorno debe ser 'dev' o 'prod'."
  }
}

variable "owner" {
  description = "Propietario / estudiante a cargo."
  type        = string
  default     = "Jose Antonio Villarroel / Fernando Galdamez"
}

variable "asignatura" {
  description = "Asignatura correspondiente."
  type        = string
  default     = "AUY1103 - Infraestructura como Codigo I"
}

variable "estudiante_nombre" {
  description = "Nombre de los integrantes a mostrar en la pagina estatica."
  type        = string
  default     = "Jose Antonio Villarroel / Fernando Galdamez"
}

variable "vpc_cidr" {
  description = "Bloque CIDR principal asignado a la VPC."
  type        = string
  default     = "10.20.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "Debe ser un bloque CIDR IPv4 valido."
  }
}

variable "instance_type" {
  description = "Tipo de instancia EC2 (compatible con AWS Academy Learner Lab)."
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
  description = "Usuario maestro de RDS MySQL."
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_name" {
  description = "Nombre inicial de la base de datos relacional."
  type        = string
  default     = "portal_db"
}

variable "habilitar_cdn" {
  description = "Bandera condicional para habilitar la rama CDN (CloudFront + S3 privado con OAC)."
  type        = bool
  default     = true
}

variable "db_instance_class" {
  description = "Tipo de instancia para la base de datos RDS MySQL."
  type        = string
  default     = "db.t3.micro"
  validation {
    condition     = can(regex("^db\\.t[23]\\.(micro|small)$", var.db_instance_class))
    error_message = "La instancia RDS debe ser db.t2.micro, db.t3.micro o db.t3.small para Learner Lab."
  }
}

variable "db_allocated_storage" {
  description = "Capacidad de almacenamiento en GiB para la base de datos RDS."
  type        = number
  default     = 20
  validation {
    condition     = var.db_allocated_storage >= 20 && var.db_allocated_storage <= 100
    error_message = "El almacenamiento de RDS debe estar entre 20 y 100 GiB."
  }
}

variable "db_engine_version" {
  description = "Version del motor de base de datos MySQL en RDS."
  type        = string
  default     = "8.0"
  validation {
    condition     = can(regex("^8\\.0", var.db_engine_version))
    error_message = "La version del motor RDS debe pertenecer a la rama MySQL 8.0."
  }
}
