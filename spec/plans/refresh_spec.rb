# frozen_string_literal: true

require 'spec_helper'
require 'bolt_spec/plans'

describe "terraform::refresh" do
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
  let(:plan_result) { { 'stdout' => 'Terraform logs' } }
  let(:output_result) { { 'my' => 'output' } }

  it 'should return logs when $output is not set' do
    allow_task('terraform::refresh').with_params(params).always_return(plan_result)
    result = run_plan('terraform::refresh', params)
    expect(result.value[0].value).to eq(plan_result)
  end

  it 'should return output when $output is set' do
    plan_params = params.merge('return_output' => true)
    sub_task_params = { 'dir' => 'foo', 'state' => 'foo' }
    allow_task('terraform::refresh').with_params(params).always_return(plan_result)
    allow_task('terraform::output').with_params(sub_task_params).always_return(output_result)
    result = run_plan('terraform::refresh', plan_params)
    expect(result.value).to eq(output_result)
  end
end
