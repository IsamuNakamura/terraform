data "local_file" "whitelist_ipv4_ips" {
  filename = "${path.cwd}/whitelist_ipv4_ips.txt"
}
