#-----------------------------------------------------------------------------------------------------
# Create new Route53 record - VPN DDNS - EMEA HUB
#-----------------------------------------------------------------------------------------------------
# Read Route53 Zone info
data "aws_route53_zone" "route53_zone" {
  name         = "${local.route53_zone_name}."
  private_zone = false
}
# Create a health-check and FGT records
resource "aws_route53_health_check" "eu_hub_vpn_fqdn_hcks" {
  for_each = local.eu_hub_public_eips

  ip_address        = each.value
  port              = local.admin_port
  type              = "TCP"
  failure_threshold = "5"
  request_interval  = "30"

  tags = merge(
    { Name = "${local.prefix}-eu-cwan-hck-${replace(each.key, ".", "")}" },
    local.tags
  )
}
# Create Route53 record entry with FGT HUBs public IPs
resource "aws_route53_record" "eu_hub_vpn_fqdn_fgts" {
  for_each = local.eu_hub_public_eips

  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = "${replace(each.key, ".", "")}.eu-cwan.${local.route53_zone_name}"
  type    = "A"
  ttl     = "30"
  records = [each.value]
}
# Health-check parent
resource "aws_route53_health_check" "eu_hub_vpn_fqdn_hck_parent" {
  type                   = "CALCULATED"
  child_health_threshold = 1
  child_healthchecks     = [for v in aws_route53_health_check.eu_hub_vpn_fqdn_hcks : v.id]

  tags = merge(
    { Name = "${local.prefix}-eu-cwan-hck-parent" },
    local.tags
  )
}
# Create Route53 record entry for VPN HUB
resource "aws_route53_record" "eu_hub_vpn_fqdn" {
  for_each = local.eu_hub_public_eips

  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = local.eu_hub_vpn_ddns
  type    = "CNAME"
  ttl     = 30

  weighted_routing_policy {
    weight = floor(100 / length(keys(local.eu_hub_public_eips)))
  }

  set_identifier = replace(each.key, ".", "")
  records        = [aws_route53_record.eu_hub_vpn_fqdn_fgts[each.key].name]

  health_check_id = aws_route53_health_check.eu_hub_vpn_fqdn_hck_parent.id
}