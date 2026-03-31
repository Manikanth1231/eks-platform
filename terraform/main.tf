locals {
  name = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  source      = "./modules/vpc"
  name        = local.name
  cidr        = var.vpc_cidr
  environment = var.environment
  tags        = local.common_tags
}

module "eks" {
  source             = "./modules/eks"
  name               = local.name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  cluster_version    = var.eks_cluster_version
  instance_types     = var.eks_node_instance_types
  desired_size       = var.eks_node_desired_size
  min_size           = var.eks_node_min_size
  max_size           = var.eks_node_max_size
  disk_size          = var.eks_node_disk_size
  tags               = local.common_tags
}

module "ecr" {
  source                = "./modules/ecr"
  repositories          = var.ecr_repositories
  environment           = var.environment
  image_retention_count = var.ecr_image_retention_count
  tags                  = local.common_tags
}
