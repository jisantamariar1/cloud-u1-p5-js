# PROVEEDOR DE AWS
provider "aws" {
    region = "us-east-1" # Región donde crearemos los recursos
}

# SECURITY GROUP: funciona como un firewall de la instancia
resource "aws_security_group" "mi-sg-windows" {
    name        = "mi-security-group-terraform-windows"
    description = "Security group para mi instancia Windows"
    vpc_id      = "vpc-086f0051e99707f6f"

    # INGRESS: reglas de entrada hacia nuestra instancia

    ingress {
        # RDP: permite conectarse remotamente al escritorio de Windows
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # Permite cualquier IP IPv4 (mejor usar mi IP /32)
    }

    ingress {
        # HTTP: permite que usuarios accedan a nuestro servidor web
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # EGRESS: reglas de salida desde nuestra instancia

    egress {
        # Permite salir por cualquier puerto y protocolo hacia cualquier IP IPv4
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Nota: los Security Groups son STATEFUL.
    # Las respuestas a conexiones permitidas se autorizan automáticamente.
}

# INSTANCIA EC2: máquina virtual con Windows
resource "aws_instance" "mi_instancia_windows" {

    ami           = "ami-03447ea9a0de98592" # Imagen de Windows (AMI)
    instance_type = "t3.micro"              # Tipo de instancia compatible con UEFI
    key_name      = "mi-primera-llaves-js"  # Key Pair para descifrar la contraseña inicial

    # Etiquetas para identificar nuestra instancia en AWS
    tags = {
        Name = "MiInstanciaTerraformWindows"
    }

    # Asociamos el Security Group a nuestra instancia
    vpc_security_group_ids = [aws_security_group.mi-sg-windows.id]
}
