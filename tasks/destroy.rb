#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper.rb'
require_relative '../lib/cli_helper.rb'
require 'json'
require 'open3'

# Test terraform::destroy task
class TerraformDestroy < TaskHelper
  def destroy(opts)
    dir = File.expand_path(opts[:dir]) if opts[:dir]
    cli_opts = CliHelper.transcribe_to_cli(opts, dir, ['-auto-approve', '-input=false'])

    stdout_str, stderr_str, status = if dir
                                       CliHelper.execute("terraform destroy #{cli_opts}", dir: dir)
                                     else
                                       CliHelper.execute("terraform destroy #{cli_opts}")
                                     end
    raise TaskHelper::Error.new(stderr_str, 'terraform/destroy-error') unless status == 0
    { 'stdout': stdout_str }
  end

  def task(opts)
    destroy(opts)
  end
end

TerraformDestroy.run if $PROGRAM_NAME == __FILE__
