################################################################################
# Instance
################################################################################
resource "aws_instance" "grafana" {
  ami           = var.ami_id
  instance_type = var.ec2_params.grafana.type
  subnet_id     = var.ec2_params.grafana.subnet_id
  vpc_security_group_ids  = [
    aws_security_group.grafana_server.id,
  ]
  iam_instance_profile = aws_iam_instance_profile.grafana.name

  root_block_device {
    # volume_size = 8
    # volume_type = "gp3"
    # iops = 3000
    # throughput = 125

    delete_on_termination = true # EC2終了時に削除

    encrypted  = true
    kms_key_id = var.kms_key_arn

    tags = {
      Name = "${var.label}-grafana",
    }
  }

  user_data = <<EOF
              #!/bin/bash
              export DEBIAN_FRONTEND=noninteractive

              sudo apt-get update -y
              sudo apt-get install -y apt-transport-https software-properties-common wget

              sudo mkdir -p /etc/apt/keyrings/
              wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
              echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

              sudo apt-get install -y grafana

              sudo systemctl daemon-reload
              sudo systemctl start grafana-server
              # sudo systemctl status grafana-server

              sudo systemctl enable grafana-server.service
              # sudo systemctl status grafana-server.service

            EOF

  tags = merge(
    var.tags,
    {
      Name = "${var.label}-grafana",
      Tier = var.tier,
    }
  )
}

resource "aws_eip" "grafana" {
  domain = true

  tags = merge(
    var.tags,
    {
      Name = "${var.label}-grafana",
      Tier = var.tier,
    }
  )
}

resource "aws_eip_association" "grafana" {
  instance_id   = aws_instance.grafana.id
  allocation_id = aws_eip.grafana.id
}
