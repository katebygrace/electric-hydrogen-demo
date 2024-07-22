output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.grafana.address
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.grafana.port
  sensitive   = true
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.grafana.username
  sensitive   = true
}

output "alb_hostname" {
  value = "${aws_alb.grafana-alb.dns_name}:3000"
}
