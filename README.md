# terraform

#### Table of Contents

1. [Description](#description)
2. [Requirements](#requirements)
3. [Usage](#usage)

## Description

The Terraform plugin module supports looking up target objects from a Terraform state file.

## Requirements

You will need to have installed `Terraform` on the system you wish to run bolt from. The executalbe must be on the system `$PATH`. 

## Usage

The Terraform plugin supports looking up target objects from a Terraform state file. It accepts several fields:

-   `dir`: The directory containing either a local Terraform state file or Terraform configuration to read remote state from.
-   `resource_type`: The Terraform resources to match, as a regular expression.
-   `uri`: (Optional) The property of the Terraform resource to use as the target URI.
-   `statefile`: (Optional) The name of the local Terraform state file to load, relative to `dir` (defaults to `terraform.tfstate)`.
-   `name`: (Optional) The property of the Terraform resource to use as the target name.
-   `config`: A Bolt config map where each value is the Terraform property to use for that config setting.
-   `backend`: (Optional) The type of backend to load the state form, either `remote` or `local` (defaults to `local`).

Either `uri` or `name` is required. If only `uri` is set, the value of `uri` is used as the `name`.

### Examples

```yaml
groups:
  - name: cloud-webs
    targets:
      - _plugin: terraform
        dir: /path/to/terraform/project1
        resource_type: google_compute_instance.web
        uri: network_interface.0.access_config.0.nat_ip
      - _plugin: terraform
        dir: /path/to/terraform/project2
        resource_type: aws_instance.web
        uri: public_ip
```

Multiple resources with the same name are identified as <resource>.0, <resource>.1, etc.

The path to nested properties must be separated with `.`: for example, `network_interface.0.access_config.0.nat_ip`.

For example, the following truncated output creates two targets, named `34.83.150.52` and `34.83.16.240`. These targets are created by matching the resources `google_compute_instance.web.0` and `google_compute_instance.web.1`. The `uri` for each target is the value of their `network_interface.0.access_config.0.nat_ip` property, which corresponds to the externally routable IP address in Google Cloud.

```
google_compute_instance.web.0:
  id = web-0
  cpu_platform = Intel Broadwell
  machine_type = f1-micro
  name = web-0
  network_interface.# = 1
  network_interface.0.access_config.# = 1
  network_interface.0.access_config.0.assigned_nat_ip =
  network_interface.0.access_config.0.nat_ip = 34.83.150.52
  network_interface.0.address =
  network_interface.0.name = nic0
  network_interface.0.network = https://www.googleapis.com/compute/v1/projects/cloud-app1/global/networks/default
  network_interface.0.network_ip = 10.138.0.22
  project = cloud-app1
  self_link = https://www.googleapis.com/compute/v1/projects/cloud-app1/zones/us-west1-a/instances/web-0
  zone = us-west1-a
google_compute_instance.web.1:
  id = web-1
  cpu_platform = Intel Broadwell
  machine_type = f1-micro
  name = web-1
  network_interface.# = 1
  network_interface.0.access_config.# = 1
  network_interface.0.access_config.0.assigned_nat_ip =
  network_interface.0.access_config.0.nat_ip = 34.83.16.240
  network_interface.0.address =
  network_interface.0.name = nic0
  network_interface.0.network = https://www.googleapis.com/compute/v1/projects/cloud-app1/global/networks/default
  network_interface.0.network_ip = 10.138.0.21
  project = cloud-app1
  self_link = https://www.googleapis.com/compute/v1/projects/cloud-app1/zones/us-west1-a/instances/web-1
  zone = us-west1-a
google_compute_instance.app.1:
  id = app-1
  cpu_platform = Intel Broadwell
  machine_type = f1-micro
  name = app-1
  network_interface.# = 1
  network_interface.0.access_config.# = 1
  network_interface.0.access_config.0.assigned_nat_ip =
  network_interface.0.access_config.0.nat_ip = 35.197.93.137
  network_interface.0.address =
  network_interface.0.name = nic0
  network_interface.0.network = https://www.googleapis.com/compute/v1/projects/cloud-app1/global/networks/default
  network_interface.0.network_ip = 10.138.0.23
  project = cloud-app1
  self_link = https://www.googleapis.com/compute/v1/projects/cloud-app1/zones/us-west1-a/instances/app-1
  zone = us-west1-a
```
