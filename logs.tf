# retain logs for 30 days
resource "aws_cloudwatch_log_group" "grafana_log_group" {
  name              = "/ecs/grafana-app"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_stream" "grafana_log_stream" {
  name           = "grafana-log-stream"
  log_group_name = aws_cloudwatch_log_group.grafana_log_group.name
}

#log bucket
resource "aws_s3_bucket" "lb_logs" {
  bucket = "grafana-load-balancer-logs-17" #random enough it wont be taken
}
