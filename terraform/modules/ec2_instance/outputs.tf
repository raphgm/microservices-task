output "frontend_instance_id" {
  value = aws_instance.frontend.id
}
output "backend_instance_id" {
  value = aws_instance.backend.id
}
output "jenkins_instance_id" {
  value = aws_instance.jenkins.id
}

output "jenkins-instance" {
  value = aws_instance.jenkins
}

output "aws_ami" {
  value = data.aws_ami.latest-amazon-linux-image
}

output "frontend-instance" {
  value = aws_instance.frontend
}
output "backend-instance" {
  value = aws_instance.backend
}