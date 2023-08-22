#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper.rb'
require_relative '../lib/cli_helper.rb'
require 'json'
require 'open3'

# Test terraform::apply task
class TerraformApply < TaskHelper
  def apply(opts)
    dir = File.expand_path(opts[:dir]) if opts[:dir]
    cli_opts = CliHelper.transcribe_to_cli(opts, dir, ['-auto-approve', '-input=false'])

    stdout_str, stderr_str, status = if dir
                                       CliHelper.execute("terraform apply #{cli_opts}", dir: dir)
                                     else
                                       CliHelper.execute("terraform apply #{cli_opts}")
                                     end
    raise TaskHelper::Error.new(stderr_str, 'terraform/apply-error') unless status == 0
    { 'stdout': stdout_str }
  end

  def task(opts)
    apply(opts)
  end
end

TerraformApply.run if $PROGRAM_NAME == __FILE__
