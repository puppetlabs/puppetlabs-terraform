# frozen_string_literal: true

require 'spec_helper'
require_relative 'support/terraform_bootstrap'

# Guarantees `terraform` is on PATH before any acceptance example runs.
#
# Belt-and-braces with the `ensure_terraform_installed` Rake prerequisite in
# rakelib/terraform.rake: that prerequisite covers the CI path
# (`rake litmus:acceptance:parallel`), this `before(:suite)` hook covers a
# developer running `bundle exec rspec spec/acceptance` directly. Both call
# the same idempotent TerraformBootstrap.ensure_installed!, so whichever
# runs first does the (one-time) install and the other is a no-op.
RSpec.configure do |c|
  c.before(:suite) do
    TerraformBootstrap.ensure_installed!
  end
end
