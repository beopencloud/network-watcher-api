output "cluster_name" {
  value = aws_eks_cluster.nappyme_cluster.name
}

output "cluster_id" {
  value = aws_eks_cluster.nappyme_cluster.id
}


output "eks_cluster_endpoint" {
  description = "The cluster endpoint"
  value = aws_eks_cluster.nappyme_cluster.endpoint
}

output "eks_cluster_certificate_authority" {
  description = "The certificate cluster"
  value = aws_eks_cluster.nappyme_cluster.certificate_authority
}