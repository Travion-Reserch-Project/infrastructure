output "server_public_ip" {
  description = "Public IP of the server"
  value       = aws_instance.travion_server.public_ip
}

output "server_id" {
  description = "Instance ID"
  value       = aws_instance.travion_server.id
}
