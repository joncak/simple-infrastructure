module "platform-mvp" {
  source = "../../../terraform-platform-mvp"

  name_prefix = var.name_prefix
  aws_region  = var.aws_region
  azs         = var.azs
}
