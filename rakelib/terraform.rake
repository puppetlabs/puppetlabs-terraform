# frozen_string_literal: true

# Ensures the `terraform` CLI is present on the current host before
# acceptance specs run.
#
# Background (bolt_193 debug session `acceptance-terraform-missing`):
# spec/acceptance/{apply,destroy,resolve_reference}_spec.rb shell out to
# `terraform` directly and run the `terraform::initialize` Bolt task against
# target 'localhost' -- i.e. against the CI runner host itself, not the
# Litmus-provisioned acceptance target. The self-hosted runner image used by
# puppetlabs/cat-github-actions's `module_acceptance.yml@main` reusable
# workflow does not ship `terraform`, and that workflow exposes no hook for
# injecting an install step, so the fix lives here instead.
require_relative '../spec/support/terraform_bootstrap'

desc 'Ensure the terraform CLI is available on PATH (installs a local copy if missing)'
task :ensure_terraform_installed do
  TerraformBootstrap.ensure_installed!
end

# Run once, serially, before `litmus:acceptance:parallel` fans out into N
# concurrent `bundle exec rspec` subprocesses -- avoids N installs racing
# each other. Guarded so this is a no-op when puppet_litmus (and therefore
# this task) isn't loaded, e.g. `bundle exec rake spec` for unit-only runs.
Rake::Task['litmus:acceptance:parallel'].enhance(['ensure_terraform_installed']) if Rake::Task.task_defined?('litmus:acceptance:parallel')
