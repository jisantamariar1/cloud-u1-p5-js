# Configuracion del provedor de AWS
provider "aws" {
    region = var.region
}

# 1. Security Group para las Instancias EC2
resource "aws_security_group" "mi-sg-efs-instancias-14" {
  name        = "mi-security-group-terraform-efs-instancias"
  description = "Security group para mis instancias"
  vpc_id      = "vpc-086f0051e99707f6f"
}

# 2. Security Group para el EFS
resource "aws_security_group" "mi-sg-efs-14" {
  name        = "mi-security-group-terraform-efs"
  description = "Security group para el sistema de archivos EFS"
  vpc_id      = "vpc-086f0051e99707f6f"
}

# Reglas SG Instancias

# Entrada
# Entrada SSH
resource "aws_vpc_security_group_ingress_rule" "entrada_ssh_instancias" {
  security_group_id = aws_security_group.mi-sg-efs-instancias-14.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
}

# Salida
# Salida a EFS 2049
resource "aws_vpc_security_group_egress_rule" "salida_efs" {
  security_group_id            = aws_security_group.mi-sg-efs-instancias-14.id
  ip_protocol                  = "tcp"
  from_port                    = 2049
  to_port                      = 2049
  # Destino
  referenced_security_group_id = aws_security_group.mi-sg-efs-14.id
}

# Salida a Internet all traffic
resource "aws_vpc_security_group_egress_rule" "salida_internet" {
  security_group_id = aws_security_group.mi-sg-efs-instancias-14.id
  ip_protocol       = "-1"
  # Destino
  cidr_ipv4         = "0.0.0.0/0"
}

# Reglas SG EFS
# Entrada
# Regla entrada EFS 2049
resource "aws_vpc_security_group_ingress_rule" "entrada_efs" {
  security_group_id            = aws_security_group.mi-sg-efs-14.id
  ip_protocol                  = "tcp"
  from_port                    = 2049
  to_port                      = 2049
  # Origen
  referenced_security_group_id = aws_security_group.mi-sg-efs-instancias-14.id
}

# Salida
# No se requiere reglas de salida
#Se borro la instancia