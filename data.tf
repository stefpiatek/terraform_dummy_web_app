data "http" "local_ip" {
  count = 1
  url   = "https://api64.ipify.org"
}
