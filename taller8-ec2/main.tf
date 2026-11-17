# Configuracion del provedor de AWS
provider "aws" {
    region = "us-east-1" # Region donde se desplegaran los recursos

  
}
#creamos el security group
resource "aws_security_group" "mi-sg" {
  name = "mi-security-group-terraform"
  description = "Security group para mi insntancia de tf"
  vpc_id = "vpc-086f0051e99707f6f"
  #regla de entrada para SSH
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #otra regla de entrada
    ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #regla de salida para HTTP
    egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
# Declaracion de los recursos de AWS a aprovisionar
resource "aws_instance" "mi_instancia_2" {
    #atributos de mi instancia (control+ espacio para ver opciones)
    ami = "ami-0c230065b91270bc6" #ami-0c230065b91270bc6
    instance_type = "t2.micro" #tipo de instancia
    key_name = "mi-primera-llaves-js"
    tags = {
      Name = "MiInstanciaTerraform2"
    }
    vpc_security_group_ids = [aws_security_group.mi-sg.id] #ASIGNAMOS EL SG
}