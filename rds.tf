resource "aws_db_subnet_group" "grafana-db" {
  name       = "grafana"
  subnet_ids = aws_subnet.grafana-private[*].id
}

resource "aws_security_group" "grafana-db" {
  name   = "grafana-db"
  vpc_id = aws_vpc.grafana.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["108.49.158.98/32"] #only inbound from home ip
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["108.49.158.98/32"] #only outbound from home ip
  }

}

# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.html#Appendix.PostgreSQL.CommonDBATasks.Parameters

resource "aws_db_parameter_group" "grafana-db" {
  name   = "grafana-db"
  family = "postgres16"

  parameter {
    name  = "log_connections"
    value = "1" #bool, 1 is on
  }
}

#would likely do a cluster in a production environment, not an instance
resource "aws_db_instance" "grafana" {
  identifier        = "grafana-db"
  instance_class    = "db.t3.micro" #scale up as needed
  allocated_storage = 5             #gigs
  #versions https://docs.aws.amazon.com/AmazonRDS/latest/PostgreSQLReleaseNotes/postgresql-versions.html
  engine                          = "postgres"
  engine_version                  = "16.3" #latest stable
  username                        = "root"
  password                        = var.db_password
  db_subnet_group_name            = aws_db_subnet_group.grafana-db.name
  vpc_security_group_ids          = [aws_security_group.grafana-db.id]
  parameter_group_name            = aws_db_parameter_group.grafana-db.name
  publicly_accessible             = false
  skip_final_snapshot             = true #false for production systems, but for now dont want snapshots laying around
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
}
