#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper.rb'
require_relative '../lib/cli_helper.rb'
require 'json'
require 'open3'

class TerraformDestroy < TaskHelper
  def destroy(opts)
    dir = File.expand_path(opts[:dir]) if opts[:dir]
    cli_opts = CliHelper.transcribe_to_cli(opts, dir)

    stdout_str, stderr_str, status = if dir
                                       CliHelper.execute("terraform destroy #{cli_opts}", dir: dir)
                                     else
                                       CliHelper.execute("terraform destroy #{cli_opts}")
                                     end
    if status == 0
      { 'stdout': stdout_str }
    else
      raise TaskHelper::Error.new(stderr_str, 'terraform/destroy-error')
    end
  end

  def task(opts)
    destroy(opts)
  end
end

TerraformDestroy.run if $PROGRAM_NAME == __FILE__
