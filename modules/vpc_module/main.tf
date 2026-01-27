
locals {
  base_tags = {
    Project = var.name
  }

  resource_tags = var.test_resource_tag != "" ? merge(var.tags, local.base_tags, { TestResource = var.test_resource_tag }) : merge(var.tags, local.base_tags)
}
