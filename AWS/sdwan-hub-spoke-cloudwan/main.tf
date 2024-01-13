// Create key-pair
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "aws_key_pair" "eu_keypair" {
  key_name   = "${local.prefix}-eu-keypair"
  public_key = tls_private_key.ssh.public_key_openssh
}
resource "aws_key_pair" "us_keypair" {
  key_name   = "${local.prefix}-us-keypair"
  public_key = tls_private_key.ssh.public_key_openssh
}
resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "./ssh-key/${local.prefix}-ssh-key.pem"
  file_permission = "0600"
}
# Create new random API key to be provisioned in FortiGates.
resource "random_string" "api_key" {
  length  = 30
  special = false
  numeric = true
}
# Create new random API key to be provisioned in FortiGates.
resource "random_string" "vpn_psk" {
  length  = 20
  special = false
  numeric = true
}

data "http" "my-public-ip" {
  url = "http://ifconfig.me/ip"
}
