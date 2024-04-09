data "local_file" "stripe_webhook_ipv4_ips_1" {
  filename = "${path.cwd}/.stripe/webhook_ipv4_ips_1.txt"
}

data "local_file" "stripe_webhook_ipv4_ips_2" {
  filename = "${path.cwd}/.stripe/webhook_ipv4_ips_2.txt"
}

data "local_file" "stripe_webhook_ipv4_ips_3" {
  filename = "${path.cwd}/.stripe/webhook_ipv4_ips_3.txt"
}

data "local_file" "stripe_webhook_ipv4_ips_4" {
  filename = "${path.cwd}/.stripe/webhook_ipv4_ips_4.txt"
}
