#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper.rb' unless Object.const_defined?('TaskHelper')
require_relative '../lib/cli_helper.rb'

# Test terraform::refresh task
class TerraformRefresh < TaskHelper
  def output(opts)
    dir = File.expand_path(opts[:dir]) if opts[:dir]
    cli_opts = CliHelper.transcribe_to_cli(opts, dir)

    stdout_str, stderr_str, status = if dir
                                       CliHelper.execute("terraform refresh #{cli_opts}", dir: dir)
                                     else
                                       CliHelper.execute("terraform refresh #{cli_opts}")
                                     end

    raise TaskHelper::Error.new(stderr_str, 'terraform/refresh-error') unless status == 0
    { 'stdout': stdout_str }
  end

  def task(opts)
    output(opts)
  end
end

TerraformRefresh.run if $PROGRAM_NAME == __FILE__
