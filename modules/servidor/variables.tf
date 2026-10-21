variable "nombre" {
  description = "Prefijo identificador para los recursos del servidor (EC2 y SG)."
  type        = string
}

variable "cantidad" {
  description = "Numero de instancias EC2 identicas a desplegar mediante count."
  type        = number
}

variable "ami_id" {
  description = "ID de la AMI Ubuntu 24.04 LTS a utilizar en las instancias."
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2 (ej. t3.micro o t3.small)."
  type        = string
}

variable "vpc_id" {
  description = "Identificador de la VPC donde residira el Security Group y las instancias."
  type        = string
}

variable "subnet_ids" {
  description = "Lista de subredes publicas sobre las cuales distribuir las instancias."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ID del Security Group del ALB para permitir ingreso HTTP (puerto 80)."
  type        = string
}

variable "target_group_arn" {
  description = "ARN del Target Group al que se registraran las instancias EC2."
  type        = string
}

variable "user_data" {
  description = "Script bash o cloud-init para aprovisionamiento inicial de la instancia."
  type        = string
}

variable "tags" {
  description = "Mapa de etiquetas AWS para clasificacion y gestion de costos."
  type        = map(string)
}
