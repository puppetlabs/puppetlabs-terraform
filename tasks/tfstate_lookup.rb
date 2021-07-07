#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper.rb'
require_relative '../lib/statefile_helper.rb'

class TfStateLookup < TaskHelper

  def resolve_reference(opts)
    state = StatefileHelper.load_statefile(opts)
    regex = Regexp.new(opts[:resource_type])
    resources = StatefileHelper.extract_resources(state).map do |type, resource|
      resource if type.match?(regex)
    end.compact
    
    if opts[:attribute_path]
      segments = opts[:attribute_path].split('.').map do |segment|
        begin
          # Turn it into an integer if we can
          Integer(segment)
        rescue ArgumentError
          # Otherwise return the value
          segment
        end
      end
      resources.dig(*segments)
    else 
      resources
    end

  end

  def task(opts = {})
    resolved_attribute = resolve_reference(opts)
    { value: resolved_attribute }
  end
end

TfStateLookup.run if $PROGRAM_NAME == __FILE__
