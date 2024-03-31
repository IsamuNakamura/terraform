data "local_file" "blacklist_ipv4_ips" {
  filename = "${path.cwd}/waf_rules/blacklist_ipv4_ips.txt"
}

data "local_file" "blacklist_ipv6_ips" {
  filename = "${path.cwd}/waf_rules/blacklist_ipv6_ips.txt"
}
