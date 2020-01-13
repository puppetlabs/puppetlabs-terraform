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

    if dir ? Dir.exist?("#{dir}/.terraform") : Dir.exist?(File.expand_path('.terraform'))
      return { 'stdout': 'Terraform directory already initialized' }
    end

    stdout_str, stderr_str, status = if dir
                                       CliHelper.execute("terraform init #{cli_opts}", dir: dir)
                                     else
                                       CliHelper.execute("terraform init #{cli_opts}")
                                     end

    if status == 0
      return { 'stdout': stdout_str }
    else
      raise TaskHelper::Error.new(_(stderr_str), 'terraform/init-error')
    end
  end

  def task(opts)
    init(opts)
  end
end

TerraformInitialize.run if $PROGRAM_NAME == __FILE__
