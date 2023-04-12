# This module is intended to create GCP GKE cluster and for further regulaforensics helm charts deployment
## Prerequisites

**GCP**
- Download your **credentials.json** file for using Google API
- Place credentials to folder with your module

## Preparation Steps
### Export AWS credentials

```bash
  export GOOGLE_APPLICATION_CREDENTIALS="/host/path/credentials.json"
```

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