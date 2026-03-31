output "vpc_id"             { value = module.vpc.vpc_id }
output "private_subnet_ids" { value = module.vpc.private_subnet_ids }
output "public_subnet_ids"  { value = module.vpc.public_subnet_ids }
output "eks_cluster_name"   { value = module.eks.cluster_name }
output "eks_cluster_endpoint" { value = module.eks.cluster_endpoint }
output "eks_cluster_ca"     { value = module.eks.cluster_ca  sensitive = true }
output "eks_node_role_arn"  { value = module.eks.node_role_arn }
output "ecr_repository_urls" { value = module.ecr.repository_urls }
output "configure_kubectl"  {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
