# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper.rb'
require 'open3'
require 'json'

module StatefileHelper
  class << self
    def load_statefile(opts)
      statefile = if opts[:backend] == 'remote'
                    load_remote_statefile(opts)
                  else
                    load_local_statefile(opts)
                  end

      JSON.parse(statefile)
    end

    # Uses the Terraform CLI to pull remote state files
    def load_remote_statefile(opts)
      dir = File.expand_path(opts[:dir], opts[:_boltdir])

      begin
        stdout_str, stderr_str, status = Open3.capture3('terraform state pull', chdir: dir)
      rescue Errno::ENOENT
        msg = if File.directory?(dir)
                "Could not find executable 'terraform'"
              else
                "Could not find directory '#{dir}'"
              end
        raise TaskHelper::Error.new(msg, 'bolt-plugin/validation-error')
      end

      unless status.success? && !stdout_str.empty?
        err = stdout_str + stderr_str
        msg = "Could not pull Terraform remote state file for #{dir}:\n#{err}"
        raise TaskHelper::Error.new(msg, 'bolt-plugin/validation-error')
      end

      stdout_str
    end

    def load_local_statefile(opts)
      filename = opts.fetch(:state, 'terraform.tfstate')
      File.read(File.expand_path(File.join(opts[:dir], filename), opts[:_boltdir]))
    rescue Errno::ENOENT
      # No statefile, no resources. Return empty-like state data
      { 'version' => 4, 'resources' => [], 'outputs' => {} }.to_json
    rescue StandardError => e
      msg = "Could not load Terraform state file #{filename}:\n#{e}"
      raise TaskHelper::Error.new(msg, 'bolt-plugin/validation-error')
    end

    # Format the list of resources into a list of [name, attribute map]
    # pairs. This method handles both version 4 and earlier statefiles, doing
    # the appropriate munging based on the shape of the data.
    def extract_resources(state)
      if state['version'] >= 4
        state.fetch('resources', []).flat_map do |resource_set|
          prefix = "#{resource_set['type']}.#{resource_set['name']}"
          resource_set['instances'].map do |resource|
            instance_name = prefix
            instance_name += ".#{resource['index_key']}" if resource['index_key']
            # When using `terraform state pull` with terraform >= 0.12 version 3 statefiles
            # Will be converted to version 4. When converted attributes is converted to attributes_flat
            attributes = resource['attributes'] || resource['attributes_flat']
            [instance_name, attributes]
          end
        end
      else
        state.fetch('modules', {}).flat_map do |mod|
          mod.fetch('resources', {}).map do |name, resource|
            data = resource.dig('primary', 'attributes')
            data = structure_data(data)
            [name, data]
          end
        end
      end
    end

    # Format hashed dot notation into a nested data structure that the ruby plugin helper
    # can handle. This is needed for tfstate files earlier than version 4, as the keys
    # use dot notation, which are automatically split by the ruby plugin helper and used
    # for dot indexing.
    def structure_data(data)
      data.each_with_object({}) do |(key, val), acc|
        # Attempt to coerce each key into an integer, in case it's the index for an array
        keys = key.split('.').map do |k|
          begin
            Integer(k)
          rescue ArgumentError
            k
          end
        end
        leaf = keys[0...-1].inject(acc) do |a, k|
          a[k] ||= {}
        end
        leaf[keys.last] = val
      end
    end

  end
end
