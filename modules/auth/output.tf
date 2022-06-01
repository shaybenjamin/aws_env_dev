output "key_name" {
  //value = "${aws_key_pair.key_pair.key_name}"
  value = "${aws_key_pair.demo_auth.key_name}"
}
