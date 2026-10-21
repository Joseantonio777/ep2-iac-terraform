# 1. RED (Modulo Publico)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.nombre_base}-vpc"
  cidr = var.vpc_cidr
  azs  = local.azs

  public_subnets   = local.subredes_publicas
  database_subnets = local.subredes_bd

  enable_nat_gateway                     = false
  single_nat_gateway                     = true
  create_database_subnet_group           = true
  database_subnet_group_name             = "${local.nombre_base}-db-subnets"
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true
  enable_dns_hostnames                   = true
  enable_dns_support                     = true

  tags = local.tags_comunes
}

# 2. APPLICATION LOAD BALANCERS (for_each sobre map + dynamic block)
resource "aws_security_group" "alb" {
  for_each = local.albs

  name        = "${local.nombre_base}-sg-alb-${each.key}"
  description = "Reglas ALB ${each.value.desc}"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = toset([80])
    content {
      description = "HTTP desde Internet"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags_comunes, { Name = "${local.nombre_base}-sg-alb-${each.key}" })
}

resource "aws_lb" "this" {
  for_each = local.albs

  name               = "${local.nombre_base}-alb-${each.key}"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb[each.key].id]
  subnets            = module.vpc.public_subnets

  tags = merge(local.tags_comunes, { Name = "${local.nombre_base}-alb-${each.key}" })
}

resource "aws_lb_target_group" "this" {
  for_each = local.albs

  name        = "${local.nombre_base}-tg-${each.key}"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path                = lookup(each.value, "health", "/")
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(local.tags_comunes, { Name = "${local.nombre_base}-tg-${each.key}" })
}

resource "aws_lb_listener" "http" {
  for_each = local.albs

  load_balancer_arn = aws_lb.this[each.key].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }

  tags = merge(local.tags_comunes, { Name = "${local.nombre_base}-listener-${each.key}" })
}

# 3. MODULO LOCAL SERVIDOR (Reutilizado: Web Estatico y Backends Docker)
module "servidor_web" {
  source = "./modules/servidor"

  nombre                = "${local.nombre_base}-web"
  cantidad              = 1
  ami_id                = data.aws_ami.ubuntu.id
  instance_type         = var.instance_type
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.public_subnets
  alb_security_group_id = aws_security_group.alb["estatico"].id
  target_group_arn      = aws_lb_target_group.this["estatico"].arn
  user_data = templatefile("${path.module}/scripts/web.sh.tftpl", {
    estudiante = var.estudiante_nombre
    entorno    = var.environment
  })
  tags = merge(local.tags_comunes, { Rol = "estatico" })
}

module "servidor_backend" {
  source = "./modules/servidor"

  nombre                = "${local.nombre_base}-backend"
  cantidad              = var.backend_count
  ami_id                = data.aws_ami.ubuntu.id
  instance_type         = var.instance_type
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.public_subnets
  alb_security_group_id = aws_security_group.alb["backend"].id
  target_group_arn      = aws_lb_target_group.this["backend"].arn
  user_data             = file("${path.module}/scripts/backend.sh")
  tags                  = merge(local.tags_comunes, { Rol = "backend" })
}

# 4. MYSQL RDS
resource "random_password" "db" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_security_group" "rds" {
  name        = "${local.nombre_base}-sg-rds"
  description = "Acceso a MySQL"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Acceso desde backends"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [module.servidor_backend.security_group_id]
  }

  ingress {
    description = "Acceso desde IP publica actual (DBeaver)"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [local.mi_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags_comunes, { Name = "${local.nombre_base}-sg-rds" })
}

resource "aws_db_instance" "mysql" {
  identifier     = "${local.nombre_base}-mysql"
  engine         = "mysql"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage = var.db_allocated_storage
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result

  db_subnet_group_name   = module.vpc.database_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = true
  multi_az               = false

  skip_final_snapshot = true
  deletion_protection = false

  tags = merge(local.tags_comunes, { Name = "${local.nombre_base}-mysql" })
}
