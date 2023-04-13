output "cluster_name" {
  description = "Cluster name"
  value       = module.gke_cluster.cluster_name
}

output "config" {
  description = "Cluster name"
  value       = module.gke_auth.kubeconfig_raw
}
