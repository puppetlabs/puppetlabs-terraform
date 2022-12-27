#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper.rb'
require_relative '../lib/cli_helper.rb'

class TerraformRefresh < TaskHelper
  def output(opts)
    cli_opts = %w[-no-color -json]
    dir = File.expand_path(opts[:dir]) if opts[:dir]
    cli_opts << "-state=#{File.expand_path(opts[:state], dir)}" if opts[:state]
    cli_opts << "-var-file=#{File.expand_path(opts[:var_file], dir)}" if opts[:var_file]
    cli_opts = cli_opts.join(' ')

    stdout_str, stderr_str, status = if dir
                                       CliHelper.execute("terraform refresh #{cli_opts}", dir: dir)
                                     else
                                       CliHelper.execute("terraform refresh #{cli_opts}")
                                     end
    if status == 0
      { 'stdout': stdout_str }
    else
      raise TaskHelper::Error.new(stderr_str, 'terraform/refresh-error')
    end
  end

  def task(opts)
    output(opts)
  end
end

TerraformRefresh.run if $PROGRAM_NAME == __FILE__
