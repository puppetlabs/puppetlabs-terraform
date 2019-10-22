#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper.rb'
require 'json'
require 'open3'

class Terraform < TaskHelper
  def resolve_reference(opts)
    state = load_statefile(opts)
    resources = extract_resources(state)
    regex = Regexp.new(opts[:resource_type])

    resources.select do |name, _resource|
      name.match?(regex)
    end.map do |name, resource|
      target = {}
      if opts.key?(:uri)
        uri = lookup(name, resource, opts[:uri])
        target['uri'] = uri if uri
      end
      if opts.key?(:name)
        real_name = lookup(name, resource, opts[:name])
        target['name'] = real_name if real_name
      end
      if opts.key?(:config)
        target['config'] = resolve_config(name, resource, opts[:config])
      end
      target
    end.compact
  end

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
    dir = File.expand_path(opts[:dir])

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

    unless status.success?
      err = stdout_str + stderr_str
      msg = "Could not pull Terraform remote state file for #{opts[:dir]}:\n#{err}"
      raise TaskHelper::Error.new(msg, 'bolt-plugin/validation-error')
    end

    stdout_str
  end

  def load_local_statefile(opts)
    dir = opts[:dir]
    filename = opts.fetch(:statefile, 'terraform.tfstate')
    File.read(File.expand_path(File.join(dir, filename)))
  rescue StandardError => e
    msg = "Could not load Terraform state file #{filename}: #{e}"
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
          [name, resource.dig('primary', 'attributes')]
        end
      end
    end
  end

  # Look up a nested value from the resource attributes. The key is of the
  # form `foo.bar.0.baz`. For terraform statefile version 3, this will
  # exactly correspond to a key in the resource. In version 4, it will
  # correspond to a nested hash entry at {foo: {bar: [{baz: <value>}]}}
  # For simplicity's sake, we just check both.
  def lookup(_name, resource, path)
    segments = path.split('.').map do |segment|
      begin
        Integer(segment)
      rescue ArgumentError
        segment
      end
    end

    resource[path] || resource.dig(*segments)
  end

  # Walk the "template" config mapping provided in the plugin config and
  # replace all values with the corresponding value from the resource
  # parameters.
  def resolve_config(name, resource, config_template)
    walk_vals(config_template) do |value|
      if value.is_a?(String)
        lookup(name, resource, value)
      else
        value
      end
    end
  end

  # Accepts a Data object and returns a copy with all hash and array values
  # Arrays and hashes including the initial object are modified before
  # their descendants are.
  def walk_vals(data, skip_top = false, &block)
    data = yield(data) unless skip_top
    if data.is_a? Hash
      map_vals(data) { |v| walk_vals(v, &block) }
    elsif data.is_a? Array
      data.map { |v| walk_vals(v, &block) }
    else
      data
    end
  end

  def map_vals(hash)
    hash.each_with_object({}) do |(k, v), acc|
      acc[k] = yield(v)
    end
  end

  def task(opts)
    targets = resolve_reference(opts)
    return { value: targets }
  rescue TaskHelper::Error => e
    # ruby_task_helper doesn't print errors under the _error key, so we have to
    # handle that ourselves
    return { _error: e.to_h }
  end
end

Terraform.run if $PROGRAM_NAME == __FILE__
