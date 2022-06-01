output "jenkins_master_ec2_id" {
  value = "${aws_instance.jenkins_master.id}"
}

output "jenkins_agent_ec2_id" {
  value = "${aws_instance.jenkins_agent.id}"
}
