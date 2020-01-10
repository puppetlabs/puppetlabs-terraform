#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper.rb'
require_relative '../lib/cli_helper.rb'
require 'json'
require 'open3'

class TerraformInitialize < TaskHelper
  def init(opts)
    cli_opts = %w[-no-color]
    dir = File.expand_path(opts[:dir]) if opts[:dir]
    cli_opts = cli_opts.join(' ')

    stdout, stderr, check_init_status = if dir
                                CliHelper.execute("terraform providers", dir: dir)
                              else
                                CliHelper.execute("terraform providers")
                              end
    if check_init_status != 0 || opts[:reinit]

      stdout_str, stderr_str, status = if dir
                                         CliHelper.execute("terraform init #{cli_opts}", dir: dir)
                                       else
                                         CliHelper.execute("terraform init #{cli_opts}")
                                       end

      if status == 0
        { 'stdout': stdout_str }
      else
        raise TaskHelper::Error.new(_(stderr_str), 'terraform/init-error')
      end
    else
      { 'stdout': "Terraform directory already initialized" }
    end
  end

  def task(opts)
    init(opts)
  end
end

TerraformInitialize.run if $PROGRAM_NAME == __FILE__
