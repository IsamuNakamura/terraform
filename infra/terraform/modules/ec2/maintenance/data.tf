data "aws_ami" "amazon_linux_2" {
  # 最新のAMIのIDを取得
  most_recent = true
  # どのアカウントから取得するか(amazon/self/microsoft...)
  owners = ["amazon"]

  # filterを使ってリソースを絞り込む
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

data "http" "my_ip" {
  url = "https://api.ipify.org?format=text"
}
