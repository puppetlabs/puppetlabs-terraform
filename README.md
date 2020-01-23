# terraform

#### Table of Contents

1. [Description](#description)
2. [Requirements](#requirements)
3. [Usage](#usage)

## Description

The Terraform plugin module supports looking up target objects from a Terraform state file, applying, destroying and querying outputs from Terraform project directories.

## Requirements

You will need to have installed `Terraform` on the system you wish to run bolt from. The executable must be on the system `$PATH`. 

## Inventory plugin usage

The `resolve_reference` task supports looking up target objects from a Terraform state file. It accepts several fields:

-   `dir`: The directory containing either a local Terraform state file or Terraform configuration to read remote state from. Relative to the active Boltdir unless absolute path is specified.
-   `resource_type`: The Terraform resources to match, as a regular expression.
-   `state`: (Optional) The name of the local Terraform state file to load, relative to `dir` (defaults to `terraform.tfstate)`.
-   `backend`: (Optional) The type of backend to load the state form, either `remote` or `local` (defaults to `local`).
-   `target_mapping`: A hash of target attributes to populate with resource values (e.g. `target_mapping: { name: 'id' }`).

The `target_mapping` parameter requires either a `uri` or `name` field. If only `uri` is set, the value of `uri` is used as the `name`.

### Examples

```yaml
groups:
  - name: cloud-webs
    targets:
      - _plugin: terraform
        dir: /path/to/terraform/project1
        resource_type: google_compute_instance.web
        target_mapping:
          uri: network_interface.0.access_config.0.nat_ip
      - _plugin: terraform
        dir: /path/to/terraform/project2
        resource_type: aws_instance.web
        target_mapping:
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

## Setting up Terraform project directories

The `initialize` task will setup a Terraform project directory with all the appropriate modules and providers needed to execute your configuration. It accepts a single field:

-   `dir`: (Optional) Path to Terraform project directory. Path is relative to CWD, unless an absolute path is specified.

## Provisioning resources 

The `apply` task will apply resources and return the logs printed to stdout. It accepts several fields:

-   `dir`: (Optional) Path to Terraform project directory. Path is relative to CWD, unless an absolute path is specified.
-   `state`: (Optional) Path to read and save state. Defaults to `terraform.tfstate`. Path is relative to `dir`.
-   `state_out`: (Optional) Path to write state to that is different than `state`. This can be used to preserve the old state. Path is relative to `dir`.
-   `target`: (Optional) Resource to target. Operation will be limited to this resource and its dependencies. Accepts a single resource string or an array of resources.
-   `var`: (Optional) Set Terraform variables, expects a hash with key value pairs representing variables and values (NOTE: single quotes `'` are incompatible).
-   `var_file`: (Optional) Set variables in the Terraform configuration from a file. Path is relative to `dir`.

The `apply` plan will run the `apply` task against the `localhost` target and optionally return the result of the `output` task. It accepts several fields:

-   `dir`: (Optional) Path to Terraform project directory. Path is relative to CWD, unless an absolute path is specified.
-   `state`: (Optional) Path to read and save state. Defaults to `terraform.tfstate`. Path is relative to `dir`.
-   `state_out`: (Optional) Path to write state to that is different than `state`. This can be used to preserve the old state. Path is relative to `dir`.
-   `target`: (Optional) Resource to target. Operation will be limited to this resource and its dependencies. Accepts a single resource string or an array of resources.
-   `var`: (Optional) Set Terraform variables, expects a hash with key value pairs representing variables and values (NOTE: single quotes `'` are incompatible).
-   `var_file`: (Optional) Set variables in the Terraform configuration from a file. Path is relative to `dir`.
-   `return_output`: (Optional) Return the result of the `output` task (defualts to `false`). 

The `output` task will return the result of executing `terraform output`. It accepts several fields:

-   `dir`: (Optional) Path to Terraform project directory. Path is relative to CWD, unless an absolute path is specified.
-   `state`: (Optional) Path to read and save state. Defaults to `terraform.tfstate`. Path is relative to `dir`.

## Destroying resources

The `destroy` task will destroy resources and return the logs printed to stdout. It accepts several fields:

-   `dir`: (Optional) Path to Terraform project directory. Path is relative to CWD, unless an absolute path is specified.
-   `state`: (Optional) Path to read and save state. Defaults to `terraform.tfstate`. Path is relative to `dir`.
-   `state_out`: (Optional) Path to write state to that is different than `state`. This can be used to preserve the old state. Path is relative to `dir`.
-   `target`: (Optional) Resource to target. Operation will be limited to this resource and its dependencies. Accepts a single resource string or an array of resources.
-   `var`: (Optional) Set Terraform variables, expects a hash with key value pairs representing variables and values (NOTE: single quotes `'` are incompatible).
-   `var_file`: (Optional) Set variables in the Terraform configuration from a file. Path is relative to `dir`.

The `destroy` plan will run the `destroy` task against the `localhost` and return it's result. It accepts several fields:

-   `dir`: (Optional) Path to Terraform project directory. Path is relative to CWD, unless an absolute path is specified.
-   `state`: (Optional) Path to read and save state. Defaults to `terraform.tfstate`. Path is relative to `dir`.
-   `state_out`: (Optional) Path to write state to that is different than `state`. This can be used to preserve the old state. Path is relative to `dir`.
-   `target`: (Optional) Resource to target. Operation will be limited to this resource and its dependencies. Accepts a single resource string or an array of resources.
-   `var`: (Optional) Set Terraform variables, expects a hash with key value pairs representing variables and values (NOTE: single quotes `'` are incompatible).
-   `var_file`: (Optional) Set variables in the Terraform configuration from a file. Path is relative to `dir`.


### Example

In this example plan, resources are applied and then destroyed during plan execution. The outputs from the `terraform::apply` plan are used to pass as data to a task. 

```puppet
plan example(TargetSpec $targets){
  run_task('terraform::initialize', 'dir' => '/home/cas/working_dir/dynamic-inventory-demo')
  $apply_result = run_plan('terraform::apply', 'dir' => '/home/cas/working_dir/dynamic-inventory-demo', 'return_output' => true)
  run_task('important::stuff', $targets, 'task_var' => $apply_result)
  run_plan('destroy', 'dir' => '/home/cas/working_dir/dynamic-inventory-demo')
}
```
