################################################################################
# Keypair
################################################################################
resource "tls_private_key" "keygen" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "keypair_maintenance" {
  key_name   = "${var.label}-maintenance"
  public_key = tls_private_key.keygen.public_key_openssh
}

resource "aws_ssm_parameter" "keypair_maintenance" {
  name  = "/${join("/", split("-", var.label))}/keypair/maintenance"
  type  = "SecureString"
  value = tls_private_key.keygen.private_key_pem
}

# remote-exec実行後は削除
resource "local_file" "keypair_maintenance_file" {
  content  = tls_private_key.keygen.private_key_pem
  filename = "${path.cwd}/keypair/maintenance.pem"
}

################################################################################
# Instance
################################################################################
resource "aws_instance" "maintenance" {
  ami           = data.aws_ami.amazon_linux_2.id
  # ami           = "ami-06b33d4abd65831dd"
  instance_type = var.ec2_params.maintenance.type
  subnet_id     = var.ec2_params.maintenance.subnet_id
  vpc_security_group_ids  = [
    aws_security_group.maintenance_server.id,
  ]
  iam_instance_profile = aws_iam_instance_profile.maintenance.name

  key_name = aws_key_pair.keypair_maintenance.id

  user_data = <<EOF
              #!/bin/bash
              sudo yum list installed | grep mariadb
              sudo yum remove mariadb-libs
              sudo yum localinstall -y https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
              sudo yum-config-manager --disable mysql57-community
              sudo yum-config-manager --enable mysql80-community
              sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
              sudo yum install -y mysql-community-client
              sudo yum install -y mysql
              mysql --version
              echo "0 0 * * * ec2-user /usr/bin/bash /home/ec2-user/scripts/mysql_dump.sh >> /home/ec2-user/dbdump/logs/dbdump.cron.log 2>&1" | sudo tee /tmp/user_cron > /dev/null
              sudo crontab -u ec2-user /tmp/user_cron
              sudo rm /tmp/user_cron
            EOF

  tags = merge(
    var.tags,
    {
      Name = "${var.label}-maintenance",
      Tier = var.tier,
    }
  )
}

resource "aws_eip" "maintenance" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.label}-maintenance",
      Tier = var.tier,
    }
  )
}

resource "aws_eip_association" "maintenance" {
  instance_id   = aws_instance.maintenance.id
  allocation_id = aws_eip.maintenance.id
}

resource "local_file" "dbdump_cnf" {
  content  = file("${path.module}/config/.dbdump.cnf")
  filename = "/tmp/.dbdump.cnf"
}

resource "local_file" "mysql_cnf" {
  content  = file("${path.cwd}/config/.db.cnf")
  filename = "/tmp/.db.cnf"
}

resource "local_file" "create_db_sql" {
  content  = file("${path.cwd}/sql/create_db.sql")
  filename = "/tmp/create_db.sql"
}

resource "local_file" "mysql_dump" {
  content  = file("${path.cwd}/scripts/mysql_dump.sh")
  filename = "/tmp/mysql_dump.sql"
}

resource "local_file" "db_restore" {
  content  = file("${path.cwd}/scripts/db_restore.sh")
  filename = "/tmp/db_restore.sql"
}

resource "null_resource" "db_setup" {

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(local_file.keypair_maintenance_file.filename)
    host        = aws_eip.maintenance.public_ip
  }

  provisioner "file" {
    source      = local_file.create_db_sql.filename
    destination = "/home/ec2-user/create_db.sql"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir /home/ec2-user/scripts",
      "chmod 755 /home/ec2-user/scripts",
      "mkdir -p /home/ec2-user/dbdump/logs",
      "chmod -R 755 /home/ec2-user/dbdump/",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(local_file.keypair_maintenance_file.filename)
      host        = aws_eip.maintenance.public_ip
    }
  }

  provisioner "file" {
    source      = local_file.mysql_cnf.filename
    destination = "/home/ec2-user/config/.db.cnf"
  }

  provisioner "file" {
    source      = local_file.dbdump_cnf.filename
    destination = "/home/ec2-user/config/.dbdump.cnf"
  }

  provisioner "file" {
    source      = local_file.mysql_dump.filename
    destination = "/home/ec2-user/scripts/mysql_dump.sh"
  }

  provisioner "file" {
    source      = local_file.db_restore.filename
    destination = "/home/ec2-user/scripts/db_restore.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 120", # インスタンス作成して、mysqlコマンドをインストールするが使用できるまで時間がかかるので、待つ
      "mysql --defaults-extra-file=/home/ec2-user/config/.db.cnf < /home/ec2-user/create_db.sql",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(local_file.keypair_maintenance_file.filename)
      host        = aws_eip.maintenance.public_ip
    }
  }

  depends_on = [
    aws_key_pair.keypair_maintenance,
    local_file.keypair_maintenance_file,
    aws_instance.maintenance,
    aws_eip.maintenance,
    aws_eip_association.maintenance,
    local_file.create_db_sql,
    local_file.mysql_cnf,
  ]
}
