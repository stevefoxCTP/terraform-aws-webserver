output "instance_id" {
  value = "${aws_instance.private_module_instance.id}"
}

output "instance_public_ip" {
  value = "${aws_instance.private_module_instance.public_ip}"
}
