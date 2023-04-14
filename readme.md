# This module is intended to create GCP GKE cluster and for further regulaforensics helm charts deployment
## Prerequisites

**GCP**
- Create GCP project
- Create service account (https://cloud.google.com/iam/docs/service-accounts-create)
- Create and download service account key **credentials.json** file for using Google API (https://cloud.google.com/iam/docs/keys-create-delete)
- Place credentials to the folder with your module

## Preparation Steps
### Export AWS credentials

```bash
  export GOOGLE_APPLICATION_CREDENTIALS="/host/path/credentials.json"
```

### Enable Cloud Resource Manager 

- Add your **project_id** to the following Url and enable cloud resource manager API https://console.developers.google.com/apis/api/cloudresourcemanager.googleapis.com/overview?project=<PROJECT_ID>


### Create terraform main.tf file and pass required variables **project_id**, **region**, **zones** and **name**

```hcl
module "gke_cluster" {
  source            = "github.com/regulaforensics/terraform-gcp-regulaforensics-demo"
  project_id        = var.project_id
  region            = var.region
  zones             = var.zones
  name              = var.name
  enable_docreader  = true
  enable_faceapi    = true
}
```
### To access your cluster, add the following resource
```hcl
resource "local_file" "kubeconfig" {
  content  = module.gke_cluster.config
  filename = "${path.module}/kubeconfig"

  depends_on = [
    module.gke_cluster
  ]
}
```
This will create a kubernetes config file, to access your cluster

## Add Regula license for your chart
```hcl
data "template_file" "docreader_license" {
  template = filebase64("${path.module}/license/docreader/regula.license")
}
```
```hcl
data "template_file" "face_api_license" {
  template = filebase64("${path.module}/license/faceapi/regula.license")
}
```
```hcl
module "gke_cluster" {
  ...
  docreader_license  = data.template_file.docreader_license.rendered
  face_api_license   = data.template_file.face_api_license.rendered
  ...
}
```
## Execute terraform template
```bash
  terraform init
  terraform plan
  terraform apply
```

## Optional. Custom Helm values

### Custom values for docreader chart
If you are about to deploy docreader Helm chart with custom values:
- create **values.yml** in folder named by application (i.e. values/docreader/values.yml)
- pass file location to the `template_file` of `data source` block
```hcl
data "template_file" "docreader_values" {
  template = file("${path.module}/values/docreader/values.yml")
}
```
### Custom values for faceapi chart
If you are about to deploy faceapi Helm chart with custom values:
- create **values.yml** in folder named by application (i.e. values/faceapi/values.yml)
- pass file location to the `template_file` of `data source` block
```hcl
data "template_file" "faceapi_values" {
  template = file("${path.module}/values/faceapi/values.yml")
}
```

Finally, pass rendered template files to the `docreader_values/faceapi_values` variables
```
module "gke_cluster" {
  source           = "github.com/regulaforensics/terraform-gcp-regulaforensics-demo"
  enable_docreader = true
  enable_faceapi   = true
  docreader_values = data.template_file.docreader_values.rendered
  faceapi_values   = data.template_file.faceapi_values.rendered
  ...
}
```



## **Inputs**
| Name                          | Description                                                                           | Type          |Default                                |
| ------------------------------|---------------------------------------------------------------------------------------|---------------|---------------------------------------|
| project_id                    | The region to host the cluster in (optional if zonal cluster / required if regional)  | string        | null                                  |
| region                        | AWS Region                                                                            | string        | null                                  |
| regional                      | Whether is a regional cluster (zonal cluster if set false                             | bool          | false                                 |
| zones                         | Zones to deploy cluster                                                               | string        | null                                  |
| name                          | Name of your cluster                                                                  | list(string)  | null                                  |
| master_authorized_networks    | List of master authorized networks                                                    |list(map(string)) | [{cidr_block="0.0.0.0/0",display_name="Open for all"}]|
| enable_private_endpoint       | Whether the master's internal IP address is used as the cluster endpoint              | bool          | false                                 |
| enable_private_nodes          | Whether nodes have internal IP addresses only                                         | bool          | true                                  |
| subnet_private_access         | When enabled, VMs in this subnetwork without external IP addresses                    | bool          | true                                  |
| subnet_ip_range               | The range of IP addresses belonging to this subnetwork secondary range                | string        | 10.1.0.0/28                           |
| secondary_ip_ranges           |An array of configurations for secondary IP ranges for VM instances contained in this subnetwork | list(map(string))   | [{range_name="k8s-pod-range" ip_cidr_range = "10.48.0.0/14"},{range_name="k8s-service-range" ip_cidr_range = "10.52.0.0/20"}]   |
| node_count                    | The number of nodes in the nodepool when autoscaling is false                         | string        | 1                                     |
| disk_size_gb                  | Size of the disk attached to each node, specified in GB                               | string        | 100                                   |
| disk_type                     | Type of the disk attached to each node                                                | string        | pd-standard                           |
| machine_type                  | The name of a Google Compute Engine machine type                                      | string        | e2-standard-4                         |
| spot                          | A boolean that represents whether the underlying node VMs are spot                    | bool          | true                                  |
| enable_docreader              | Deploy Docreader helm chart                                                           | bool          | false                                 |
| docreader_values              | Docreader helm values                                                                 | string        | null                                  |
| docreader_license             | Docreader Regula license file                                                         | string        | null                                  |
| enable_faceapi                | Deploy Faceapi helm chart                                                             | bool          | false                                 |
| faceapi_values                | Faceapi helm values                                                                   | string        | null                                  |
| face_api_license              | Faceapi Regula license file                                                           | string        | null                                  |