output "elb-frontend" {
  value = var.elb_frontend_pip != null ? var.elb_frontend_pip : google_compute_address.elb_frontend_pip.id
}