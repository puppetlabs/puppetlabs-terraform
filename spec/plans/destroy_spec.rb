# frozen_string_literal: true

require 'spec_helper'
require 'bolt_spec/plans'

describe 'terraform::destroy' do
  include BoltSpec::Plans
  BoltSpec::Plans.init

  let(:params) do
    {
      'dir' => 'foo',
      'state' => 'foo',
      'state_out' => 'foo',
      'target' => 'foo',
      'var' => { 'foo' => 'bar' },
      'var_file' => 'foo'
    }
  end
  let(:bolt_config) { { 'modulepath' => RSpec.configuration.module_path } }
  let(:destroy_result) { { 'stdout' => 'Terraform logs' } }

  it 'returns logs from destroy task' do
    allow_task('terraform::destroy').with_params(params).always_return(destroy_result)
    result = run_plan('terraform::destroy', params)
    expect(result.value[0].value).to eq(destroy_result)
  end
end
