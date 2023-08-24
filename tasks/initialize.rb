#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper.rb' unless Object.const_defined?('TaskHelper')
require_relative '../lib/cli_helper.rb'

# Test terraform::initialize task
class TerraformInitialize < TaskHelper
  def init(opts)
    dir = File.expand_path(opts[:dir]) if opts[:dir]
    if dir ? Dir.exist?("#{dir}/.terraform") : Dir.exist?(File.expand_path('.terraform'))
      return { 'stdout': 'Terraform directory already initialized' }
    end

    cli_opts = CliHelper.transcribe_to_cli(opts, dir)

    stdout_str, stderr_str, status = if dir
                                       CliHelper.execute("terraform init #{cli_opts}", dir: dir)
                                     else
                                       CliHelper.execute("terraform init #{cli_opts}")
                                     end

    return { 'stdout': stdout_str } if status == 0

    raise TaskHelper::Error.new(_(stderr_str), 'terraform/init-error')
  end

  def task(opts)
    init(opts)
  end
end

TerraformInitialize.run if $PROGRAM_NAME == __FILE__
