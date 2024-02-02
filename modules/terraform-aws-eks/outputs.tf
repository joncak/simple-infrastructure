output "eks_cluster_autoscaler_arn" {
  value       = aws_iam_role.eks_cluster_autoscaler.arn
  description = "value of the ARN of the IAM role for the EKS Cluster Autoscaler"
}