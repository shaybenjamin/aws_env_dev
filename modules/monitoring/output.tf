
output "prometheus_access_key" {
  value = "${aws_iam_access_key.prometheus_access_key}"
}

output "prometheus_sg" {
  value = "${aws_security_group.prometheus_sg}"
}