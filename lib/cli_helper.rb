# frozen_string_literal: true

require 'open3'

module CliHelper
  class << self
    # Execute a Terraform command with open3.
    # Supported option is `:dir` which is optionally the path to the Terraform project dir
    def execute(command, opts = {})
      if opts[:dir]
        begin
          Open3.capture3(command, chdir: opts[:dir])
        rescue Errno::ENOENT => e
          raise TaskHelper::Error.new(e.message, 'terraform/validation-error')
        end
      else
        begin
          Open3.capture3(command)
        rescue Errno::ENOENT => e
          raise TaskHelper::Error.new(e.message, 'terraform/validation-error')
        end
      end
    end

    # The apply and destroy CLI opts map from the same task opts to cli opts, share that code.
    def transcribe_to_cli(opts, dir = nil)
      cli_opts = %w[-auto-approve -no-color -input=false]
      cli_opts << "-state=#{File.expand_path(opts[:state], dir)}" if opts[:state]
      cli_opts << "-state-out=#{File.expand_path(opts[:state_out], dir)}" if opts[:state_out]

      if opts[:target]
        resources = opts[:target].is_a?(Array) ? opts[:target] : Array(opts[:target])
        resources.each { |resource| cli_opts << "-target=#{resource}" }
      end

      opts[:var].each { |k, v| cli_opts << "-var '#{k}=#{v}'" } if opts[:var]

      if opts[:var_file]
        var_file_paths = opts[:var_file].is_a?(Array) ? opts[:var_file] : Array(opts[:var_file])
        var_file_paths.each { |path| cli_opts << "-var-file=#{File.expand_path(path, dir)}" }
      end

      cli_opts.join(' ')
    end
  end
end
