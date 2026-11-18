# Configuracion del provedor de AWS
provider "aws" {
    region = var.region
}

# 1. Security Group para las Instancias EC2
resource "aws_security_group" "mi-sg-efs-instancias" {
  name        = "mi-security-group-terraform-efs-instancias"
  description = "Security group para mis instancias"
  vpc_id      = "vpc-086f0051e99707f6f"

  # Regla de entrada para SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla de entrada para HTTP (si la necesitas)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla de salida: Permite tráfico hacia el puerto 2049 (NFS) apuntando CRUZADO al SG del EFS
  egress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.mi-sg-efs.id]
  }

  # Regla de salida general por defecto (necesaria para internet, actualizaciones, etc.)
  egress {
    from_port   = 0 #singnica desde cualquier puerto
    to_port     = 0
    protocol    = "-1" #all trafic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Security Group para el EFS
resource "aws_security_group" "mi-sg-efs" {
  name        = "mi-security-group-terraform-efs"
  description = "Security group para el sistema de archivos EFS"
  vpc_id      = "vpc-086f0051e99707f6f"

  # Regla de entrada cruzada: Permite NFS (2049) SOLO desde el SG de las instancias
  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.mi-sg-efs-instancias.id]
  }

  # Regla de salida por defecto (permite todo el tráfico saliente)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Declaracion de la Instancia EC2 asociada a su Security Group correcto
resource "aws_instance" "mi_instancia_efs" {
    ami                    = var.ami_id
    instance_type          = var.tipo_instancia
    key_name               = var.nombre_llave
    count                  = var.cantidad_instancias
    
    # Asignamos el SG de las instancias (corregido para usar vpc_security_group_ids limpiamente)
    vpc_security_group_ids = [aws_security_group.mi-sg-efs-instancias.id] 
    
    tags = {
      Name = "Mi instancia EFS - ${count.index + 1}"
    }
}