## Release 0.6.1

### Bug fixes

* **Add PDK as a gem dependency**

  PDK is now a gem dependency for the module release pipeline

## Release 0.6.0

### New features

* **Bump maximum Puppet version to include 7.x** ([#22](https://github.com/puppetlabs/puppetlabs-terraform/pull/22))

## Release 0.5.0

### New features

* **Set `resolve_reference` task to private** ([#14](https://github.com/puppetlabs/puppetlabs-terraform/pulls/14))

    The `resolve_reference` task has been set to `private` so it no longer appears in UI lists.

### Bug fixes

* **Inventory plugin raised an exception when no statefile was found** ([#16](https://github.com/puppetlabs/puppetlabs-terraform/pulls/16))

  The `resolve_reference` task would error when no statefile was found. It now returns an empty inventory
  instead.

## Release 0.4.0

### New features

* **Added `initialize` task**

  There has been a simple `initialize` task added to the module that can be used to ensure Terraform project directories are initialized with required modules and providers installed so your code runs without manually running `terraform init` before executing a plan.

## Release 0.3.0

### New features

* **Added `target_mapping` parameter in `resolve_reference` task** ([#1405](https://github.com/puppetlabs/bolt/issues/1405))

  The `resolve_reference` task has a new `target_mapping` parameter that accepts a hash of target attributes and the resource values to populate them with.

* **Added `state` parameter in the `resolve_reference` task** ([#1405](https://github.com/puppetlabs/bolt/issues/1405))

  The `statefile` parameter for the `resolve_reference` task has been replaced with a `state` parameter to maintain consistency among the other tasks and plans in the module.

### Bug fixes

* **Raise error when remote state cannot be loaded** ([#1436](https://github.com/puppetlabs/bolt/issues/1436))

  When attempting to load remote state from a non-existent state file, `terraform` would return a `nil` value which would be loaded into the inventory and cause Bolt to error. The `terraform` plugin now checks whether the attempt to load remote state returned any data and errors if it did not.

## Release 0.2.0

### Bug fixes

* **Expand `dir` path relative to Boltdir** ([#1162](https://github.com/puppetlabs/bolt/issues/1162))

  The `dir` option will now be expanded relative to the active Boltdir the user is running bolt with, instead of the current working directory they ran Bolt from. This is part of standardizing all configurable paths in Bolt to be relative to the Boltdir.

## Release 0.1.0

This is the initial release.
