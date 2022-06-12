output "jenkins_master_ec2_id" {
  value = "${aws_instance.jenkins_master.id}"
}

output "jenkins_agent_ec2_id" {
  value = "${aws_instance.jenkins_agent.id}"
}

output "jenkins_agent_ec2_host" {
  value = [{name = "${aws_instance.jenkins_agent.id}1", private_dns = aws_instance.jenkins_agent.private_dns}]
}