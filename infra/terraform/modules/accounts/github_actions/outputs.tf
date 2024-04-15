output "user_name" {
  value = "${aws_iam_user.this.name}"
}

output "access_key_id" {
  value = "${aws_iam_access_key.this.id}"
}

output "secret_access_key" {
  value = "${aws_iam_access_key.this.encrypted_secret}"
}

resource "local_file" "credentials" {
  content = <<EOT
Username: ${aws_iam_user.this.name}
Access Key: ${aws_iam_access_key.this.id}
Secret Key: ${aws_iam_access_key.this.encrypted_secret}
EOT
  filename = "${path.cwd}/credentials.txt"
}
