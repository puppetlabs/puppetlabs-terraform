# frozen_string_literal: true

require 'spec_helper'
require 'bolt_spec/plans'

describe "terraform::destroy" do
  include BoltSpec::Plans
  BoltSpec::Plans.init

  let(:params) {
    {
      'dir' => 'foo',
      'state' => 'foo',
      'state_out' => 'foo',
      'target' => 'foo',
      'var' => { 'foo' => 'bar' },
      'var_file' => 'foo'
    }
  }
  let(:bolt_config) { { 'modulepath' => RSpec.configuration.module_path } }
  let(:destroy_result) { { 'stdout' => 'Terraform logs' } }

  it 'should return logs from destroy task' do
    allow_task('terraform::destroy').with_params(params).always_return(destroy_result)
    result = run_plan('terraform::destroy', params)
    expect(result.value.to_data[0]['result']).to eq(destroy_result)
  end
end
