resource "aws_security_group" "security_group" {
 name   = "ecs-security-group"
 vpc_id = aws_vpc.main.id

 ingress {
   from_port   = 0
   to_port     = 0
   protocol    = -1
   self        = "false"
   cidr_blocks = ["0.0.0.0/0"]
   description = "any"
 }

 egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

resource "aws_instance" "ecs_instance" {
  ami             = "ami-08b5b3a93ed654d19"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_subnets.id
  associate_public_ip_address = true

  tags = {
    Name = "ECS-Instance"
  }
}

resource "aws_iam_role" "ecs_role" {
  name               = "ecs-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_role_policy" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_security_group" "ecs_sg" {
  name_prefix = "ecs_sg"
  vpc_id      = aws_vpc.main.id
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "devops-ecs-cluster"
}

#resource "aws_ecs_container_instance" "ecs_instance_registration" {
#  cluster            = aws_ecs_cluster.ecs_cluster.id
#  instance_id        = aws_instance.ecs_instance.id
#  depends_on         = [aws_instance.ecs_instance]
#}