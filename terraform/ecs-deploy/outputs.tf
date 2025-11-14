output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app_service.name
}

output "security_group" {
  value = aws_security_group.ecs_sg.id
}

output "subnet_public" {
  value = aws_subnet.public.id
}

##############################################
# Obtener la IP pública real del ECS Task
##############################################

data "aws_ecs_task" "monitoring_task" {
  cluster = aws_ecs_cluster.main.id
  service = aws_ecs_service.monitoring_service.name
}

data "aws_network_interface" "task_eni" {
  id = data.aws_ecs_task.monitoring_task.attachments[0].details[0].value
}

output "ecs_task_public_ip" {
  description = "IP pública real asignada a la tarea ECS"
  value       = data.aws_network_interface.task_eni.association[0].public_ip
}
