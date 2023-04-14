output "cluster_name" {
  description = "Cluster name"
  value       = module.gke_cluster.cluster_name
}

output "config" {
  description = "Cluster name"
  value       = module.gke_cluster.config
  sensitive   = true
}
