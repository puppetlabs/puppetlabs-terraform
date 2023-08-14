#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper.rb'
require_relative '../lib/cli_helper.rb'
require 'json'

class TerraformOutput < TaskHelper
  def output(opts)
    dir = File.expand_path(opts[:dir]) if opts[:dir]
    cli_opts = CliHelper.transcribe_to_cli(opts, dir, %w[-json])

    stdout_str, stderr_str, status = if dir
                                       CliHelper.execute("terraform output #{cli_opts}", dir: dir)
                                     else
                                       CliHelper.execute("terraform output #{cli_opts}")
                                     end
    if status == 0
      JSON.parse(stdout_str)
    else
      raise TaskHelper::Error.new(stderr_str, 'terraform/output-error')
    end
  end

  def task(opts)
    output(opts)
  end
end

TerraformOutput.run if $PROGRAM_NAME == __FILE__
