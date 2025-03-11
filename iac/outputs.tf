output "ecs_cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}

#output "ec2_public_ip" {
#  value = aws_instance.ecs_instance.public_ip
#}