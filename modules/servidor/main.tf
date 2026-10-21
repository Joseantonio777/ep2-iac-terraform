resource "aws_security_group" "this" {
  name        = "${var.nombre}-sg"
  description = "Trafico hacia ${var.nombre} solo desde ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP solo desde el ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.nombre}-sg" })
}

resource "aws_instance" "this" {
  count = var.cantidad

  ami                    = var.ami_id
  instance_type          = var.instance_type
  associate_public_ip_address = true
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = [aws_security_group.this.id]
  user_data              = var.user_data

  tags = merge(var.tags, {
    Name = "${var.nombre}-${count.index + 1}"
  })
}

resource "aws_lb_target_group_attachment" "this" {
  count = var.cantidad

  target_group_arn = var.target_group_arn
  target_id        = aws_instance.this[count.index].id
  port             = 80
}
