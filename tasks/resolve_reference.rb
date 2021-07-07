#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper.rb'
require_relative '../../ruby_plugin_helper/lib/plugin_helper.rb'
require_relative '../lib/statefile_helper.rb'

class Terraform < TaskHelper
  include RubyPluginHelper

  def resolve_reference(opts)
    template = opts.delete(:target_mapping) || {}
    unless template.key?(:uri) || template.key?(:name)
      msg = "You must provide a 'name' or 'uri' in 'target_mapping' for the Terraform plugin"
      raise TaskHelper::Error.new(msg, 'bolt-plugin/validation-error')
    end

    state = StatefileHelper.load_statefile(opts)
    regex = Regexp.new(opts[:resource_type])
    targets = StatefileHelper.extract_resources(state).map do |type, resource|
      resource if type.match?(regex)
    end.compact

    attributes = required_data(template)
    target_data = targets.map do |target|
      attributes.each_with_object({}) do |attr, acc|
        attr = attr.first
        acc[attr] = target.key?(attr) ? target[attr] : nil
      end
    end

    target_data.map { |data| apply_mapping(template, data) }
  end

  def task(opts = {})
    targets = resolve_reference(opts)
    { value: targets }
  end
end

Terraform.run if $PROGRAM_NAME == __FILE__
